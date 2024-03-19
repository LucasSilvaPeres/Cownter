from uuid import uuid4
from typing import Tuple
from datetime import datetime

import numpy as np
import cv2 as cv
from exif import Image as ImageEXIF

from domain import Imagem, Contagem, Voo, Piquete
from repositories import VooRepository, PiqueteRepository, ContagemRepository
from use_cases.contar_bois_piquete import (ContarBoisPiqueteInputPort,
                                           ContarBoisPiqueteOutputPort,
                                           ContarBoisPiqueteUseCase,
                                           YoloContarBois,
                                           YoloIdentificarBebedouroCoucho,
                                           YoloRecortarImagemPiquete)

from presenters import ContarBoisPiquetePresenter
from gateways import DatabaseGateway, ImagemGateway


class ContarBoisPiqueteController:
    def __init__(self,
                 imagem_gateway: ImagemGateway,
                 database_gateway: DatabaseGateway,
                 voo_repository: VooRepository,
                 piquete_repository: PiqueteRepository,
                 contagem_repository: ContagemRepository,
                 arquivo_imagem: bytes,
                 caminho_modelo_contar_bois: str,
                 caminho_modelo_identificar_bebedouro_coucho: str,
                 caminho_modelo_recortar_imagem_piquete: str,
                 equipe_id: str,
                 temperatura: float,
                 indice_pluviometrico: float):
        self.imagem_gateway = imagem_gateway
        self.contagem_repository = contagem_repository
        self.piquete_repository = piquete_repository
        self.database_gateway = database_gateway
        self.arquivo_imagem = arquivo_imagem
        self.voo_repository = voo_repository
        self.caminho_modelo_contar_bois = caminho_modelo_contar_bois
        self.caminho_modelo_identificar_bebedouro_coucho = caminho_modelo_identificar_bebedouro_coucho
        self.caminho_modelo_recortar_imagem_piquete = caminho_modelo_recortar_imagem_piquete
        self.equipe_id = equipe_id
        self.temperatura = temperatura
        self.indice_pluviometrico = indice_pluviometrico

    def _calcular_coord_decimal(self, coordenada: Tuple[float, float, float], ref: str):
        graus_decimais = coordenada[0] + coordenada[1] / 60 + coordenada[2] / 3600

        if ref == "S" or ref == "W":
            graus_decimais = -graus_decimais

        return graus_decimais

    def _extrair_informacoes_exif_imagem(self, arquivo_imagem: bytes):
        imagem_exif = ImageEXIF(arquivo_imagem)

        latitude = self._calcular_coord_decimal(imagem_exif.gps_latitude,
                                                imagem_exif.gps_latitude_ref)
        longitude = self._calcular_coord_decimal(imagem_exif.gps_longitude,
                                                 imagem_exif.gps_longitude_ref)
        altitude: float = imagem_exif.gps_altitude

        data: datetime = datetime.fromisoformat(imagem_exif.datetime_original)

        return latitude, longitude, altitude, data

    def _instanciar_imagem(self):
        id_imagem = uuid4()

        latitude, longitude, altitude, data = self._extrair_informacoes_exif_imagem(self.arquivo_imagem)

        imagem_buffer = np.frombuffer(self.arquivo_imagem, np.uint8)

        dados_imagem = cv.imdecode(imagem_buffer, -1)

        imagem_resized = cv.resize(dados_imagem, (640, 640), interpolation=cv.INTER_AREA)

        return Imagem(id_imagem, latitude, longitude, altitude, imagem_resized, data)

    def _criar_caminho_imagem(self,
                              nome_fazenda: str,
                              nome_piquete: str,
                              data_imagem: datetime) -> str:
        nome_fazenda_corrigido = nome_fazenda.lower().replace(" ", "_")
        nome_piquete_corrigido = nome_piquete.lower().replace(" ", "_").replace(":", "")
        data_formatada = datetime.strftime(data_imagem, "%Y%m%d_%H%M%S")

        caminho_imagem = f"resultados/{nome_fazenda_corrigido}/{nome_piquete_corrigido}/{data_formatada}.jpg"

        return caminho_imagem
    
    def _salvar_contagem(self, contagem: Contagem, voo: Voo):
        piquete = self.database_gateway.pegar_piquete(contagem.imagem.latitude, contagem.imagem.longitude)
        fazenda = self.database_gateway.pegar_fazenda_por_piquete(piquete)

        caminho_imagem = self._criar_caminho_imagem(fazenda.nome, piquete.nome, contagem.imagem.data)

        self.imagem_gateway.salvar_imagem(contagem.imagem, caminho_imagem)

        self.contagem_repository.salvar_contagem(contagem, caminho_imagem, voo.voo_id, piquete.id_piquete, fazenda.id_fazenda)
    
    def _salvar_contagens(self, contagens: list[Contagem], voo: Voo):
        for contagem in contagens:
            self._salvar_contagem(contagem, voo)

    def _salvar_voo_piquete(self, piquete: Piquete, voo: Voo):
        self.voo_repository.salvar_voo_piquete(voo.voo_id, piquete.id_piquete)

    def _pegar_voo(self, imagem: Imagem, fazenda_id: str, equipe_id: str, temperatura: float, indice_pluviometrico: float):
        if not self.voo_repository.existe_voo_data(imagem.data):
            voo = Voo(imagem.data, [], uuid4())

            self.voo_repository.cadastrar_voo(voo, fazenda_id, equipe_id, temperatura, indice_pluviometrico)
        else:
            voo = self.voo_repository.pegar_voo_data(imagem.data)

        return voo

    def run(self) -> ContarBoisPiqueteOutputPort:
        imagem = self._instanciar_imagem()

        algoritmo_contar_bois = YoloContarBois(self.caminho_modelo_contar_bois)
        algoritmo_identificar_bebedouro_coucho = YoloIdentificarBebedouroCoucho(self.caminho_modelo_identificar_bebedouro_coucho)
        algoritmo_recortar_imagem_piquete = YoloRecortarImagemPiquete(self.caminho_modelo_recortar_imagem_piquete)

        input_port = ContarBoisPiqueteInputPort(imagem,
                                                algoritmo_contar_bois,
                                                algoritmo_identificar_bebedouro_coucho,
                                                algoritmo_recortar_imagem_piquete)

        use_case = ContarBoisPiqueteUseCase(input_port)

        output_port = use_case.run()

        contagem = output_port.contagem

        piquete = self.piquete_repository.pegar_piquete_por_latlng(
            contagem.imagem.latitude,
            contagem.imagem.longitude)
        
        fazenda = self.database_gateway.pegar_fazenda_por_piquete(piquete)

        voo = self._pegar_voo(imagem, str(fazenda.id_fazenda), self.equipe_id, self.temperatura, self.indice_pluviometrico)

        self._salvar_voo_piquete(piquete, voo)

        self._salvar_contagem(contagem, voo)

        presenter = ContarBoisPiquetePresenter(output_port)

        return presenter.present()
