from uuid import uuid4
from typing import Generator

import numpy as np
import cv2 as cv

from numpy.typing import ArrayLike

from domain import Contagem, Imagem

from .yolo_contar_bois import YoloContarBois
from .yolo_identificar_bebedouro_coucho import YoloIdentificarBebedouroCoucho
from .yolo_recortar_imagem_piquete import YoloRecortarImagemPiquete
from .boi import Boi
from .bebedouro import Bebedouro
from .coucho import Coucho


class BoisNaoEncontradosException(Exception):
    def __init__(self, *args, **kwargs):
        super(*args, **kwargs)
        
        self.imagem : Imagem | None = kwargs.get("imagem", None)


class BebedouroCouchoiNaoEncontradosException(Exception):
    def __init__(self, *args, **kwargs):
        super(*args, **kwargs)

        self.imagem = kwargs.get("imagem", None)


class ProblemaImagemPiqueteException(Exception):
    def __init__(self, *args, **kwargs):
        super(*args, **kwargs)

        self.imagem = kwargs.get("imagem", None)


class Cores:
    vermelho: tuple[int, int, int] = (0, 0, 255)
    azul: tuple[int, int, int] = (255, 0, 0)
    verde: tuple[int, int, int] = (0, 255, 0)
    magenta: tuple[int, int, int] = (255, 0, 255)
    ciano: tuple[int, int, int] = (255, 255, 0)
    amarelo: tuple[int, int, int] = (0, 255, 255)


class ContarBoisPiqueteInputPort:
    def __init__(self,
                 imagem: Imagem,
                 algoritmo_contar_bois: YoloContarBois,
                 algoritmo_recortar_bebedouro_coucho: YoloIdentificarBebedouroCoucho,
                 algoritmo_identificar_piquete: YoloRecortarImagemPiquete):
        self.imagem = imagem
        self.algoritmo_contar_bois = algoritmo_contar_bois
        self.algoritmo_recortar_bebedouro_coucho = algoritmo_recortar_bebedouro_coucho
        self.algoritmo_identificar_piquete = algoritmo_identificar_piquete


class ContarBoisPiqueteOutputPort:
    def __init__(self, contagem: Contagem):
        self.contagem = contagem


class ContarBoisPiqueteUseCase:
    def __init__(self, input_port: ContarBoisPiqueteInputPort):
        self.input_port = input_port
    
    def _dot(self, v1, v2):
        return np.dot(v1, v2)

    def _project(self, vertices, axis):
        dots = np.dot(vertices, axis)
        return np.min(dots), np.max(dots)

    def _overlap(self, a, b):
        return a[0] <= b[1] and b[0] <= a[1]

    def _get_edges(self, vertices):
        return vertices - np.roll(vertices, shift=1, axis=0)
    
    def _get_normals(self, edges):
        return np.column_stack((-edges[:, 1], edges[:, 0]))

    def _box_vertices(self, box):
        return np.array([
            (box[0], box[1]),
            (box[2], box[1]),
            (box[2], box[3]),
            (box[0], box[3]),
        ])

    def _box_vs_polygon_collision(self, box, polygon):
        box_verts = self._box_vertices(box)
        polygon_verts = np.array(polygon, dtype=np.float32)

        box_edges = self._get_edges(box_verts)
        polygon_edges = self._get_edges(polygon_verts)

        # Ensure both box_edges and polygon_edges have the same shape
        box_edges = box_edges.reshape(-1, 2)
        polygon_edges = polygon_edges.reshape(-1, 2)

        edges = np.concatenate((box_edges, polygon_edges), axis=0)
        axes = self._get_normals(edges)

        for axis in axes:
            box_projection = self._project(box_verts, axis)
            polygon_projection = self._project(polygon_verts, axis)

            if not self._overlap(box_projection, polygon_projection):
                return False

        return True

    def _identificar_bebedouro_coucho(self, img: Imagem) -> Generator[Bebedouro | Coucho, None, None]:
        algoritmo = self.input_port.algoritmo_recortar_bebedouro_coucho

        modelo = algoritmo.pegar_modelo()

        bebedouros_couchos = algoritmo.identificar_couchos_bebedouros(modelo, img)

        return bebedouros_couchos

    def _identificar_bois(self, img: Imagem) -> Generator[Boi, None, None]:
        algoritmo = self.input_port.algoritmo_contar_bois

        modelo = algoritmo.pegar_modelo()

        bois = algoritmo.contar(modelo, img)

        return bois

    def _pegar_img_piquete(self, imagem: Imagem) -> Imagem:
        algoritmo = self.input_port.algoritmo_identificar_piquete

        modelo = algoritmo.pegar_modelo()

        dados_imagem_piquete = algoritmo.recortar_imagem_piquete(modelo, imagem)

        id_imagem = uuid4()

        imagem_recortada = Imagem(id_imagem,
                                  imagem.latitude,
                                  imagem.longitude,
                                  imagem.altitude,
                                  dados_imagem_piquete,
                                  imagem.data,)

        return imagem_recortada

    def _validar_bois_comendo_bebendo(self, bois: list[Boi], bebedouros_couchos: list[Bebedouro | Coucho]):
        bois_validados = []

        for boi in bois:
            for bebedouro_coucho in bebedouros_couchos:
                possui_colisao = self._box_vs_polygon_collision(boi.caixa, bebedouro_coucho.poligono)

                if possui_colisao:
                    estado = "Drinking-Cow" if not isinstance(bebedouro_coucho, Bebedouro) else "Eating-Cow"
                    break

                else:
                    estado = boi.estado

            boi = Boi(boi.caixa, estado)

            bois_validados.append(boi)

        return bois_validados

    def _contar_bois(self, bois: list[Boi]) -> dict[str, int]:
        qtde_bois: dict[str, int] = {
            "Lying-Cow": 0,
            "Standing-Cow": 0,
            "Eating-Cow": 0,
            "Drinking-Cow": 0}
        
        for boi in bois:
            qtde_bois[boi.estado] += 1

        return qtde_bois

    def _desenhar_bois_imagem(self, dados_imagem: ArrayLike, bois: list[Boi]):
        nova_imagem = np.copy(dados_imagem)

        for boi in bois:
            cor = Cores.vermelho

            if boi.estado == "Lying-Cow":
                cor = Cores.azul
            elif boi.estado == "Eating-Cow":
                cor = Cores.verde
            elif boi.estado == "Drinking-Cow":
                cor = Cores.amarelo

            p1 = boi.caixa[:2]
            p2 = boi.caixa[2:4]

            cv.rectangle(nova_imagem, p1, p2, cor, 1)
        
        return nova_imagem

    def _desenhar_bebedouros_couchos(self, dados_imagem: ArrayLike, bebedouros_couchos: list[Bebedouro | Coucho]):
        nova_imagem = np.copy(dados_imagem)

        for bebedouro_coucho in bebedouros_couchos:
            if isinstance(bebedouro_coucho, Bebedouro):
                cor = Cores.ciano
            else:
                cor = Cores.magenta

            cv.polylines(nova_imagem, bebedouro_coucho.poligono, isClosed=True, color=cor)

        return nova_imagem
    
    def _desenhar_resultados_imagem(self, imagem: Imagem, bois: list[Boi], bebedouros_couchos: list[Bebedouro | Coucho]):
        imagem_com_bois = self._desenhar_bois_imagem(imagem.dados, bois)

        imagem_com_bebedouros_couchos = self._desenhar_bebedouros_couchos(imagem_com_bois, bebedouros_couchos)          

        imagem = Imagem(imagem.id_imagem, imagem.latitude, imagem.longitude, imagem.altitude, imagem_com_bebedouros_couchos, imagem.data)

        return imagem
    
    def _contar(self, imagem: Imagem) -> Contagem:
        img_recortada = self._pegar_img_piquete(imagem)

        try:
            bebedouros_couchos = list(self._identificar_bebedouro_coucho(img_recortada))
        except Exception:
            raise BebedouroCouchoiNaoEncontradosException()

        try:
            bois = list(self._identificar_bois(img_recortada))
        except Exception:
            raise BoisNaoEncontradosException()

        bois_comendo_bebendo = self._validar_bois_comendo_bebendo(bois, bebedouros_couchos)

        qtde_bois = self._contar_bois(bois_comendo_bebendo)

        imagem_com_resultados = self._desenhar_resultados_imagem(img_recortada, bois_comendo_bebendo, bebedouros_couchos)

        id_contagem = uuid4()

        return Contagem(id_contagem,
                        qtde_bois["Lying-Cow"],
                        qtde_bois["Standing-Cow"],
                        qtde_bois["Eating-Cow"],
                        qtde_bois["Drinking-Cow"],
                        imagem.data,
                        imagem_com_resultados)

    def run(self) -> ContarBoisPiqueteOutputPort:
        contagem = self._contar(self.input_port.imagem)

        output_port = ContarBoisPiqueteOutputPort(contagem)

        return output_port
