from uuid import uuid4
from datetime import datetime


import cv2 as cv

from exif import Image as ImageExif
from numpy.typing import ArrayLike

from domain import Imagem
from use_cases.contar_bois_piquete import ContarBoisPiqueteUseCase, ContarBoisPiqueteInputPort
from use_cases.contar_bois_piquete import YoloContarBois, YoloIdentificarBebedouroCoucho, YoloRecortarImagemPiquete


def pegar_data_imagem(caminho_imagem: ArrayLike):
    img_exif = ImageExif(caminho_imagem)

    data: datetime = datetime.strptime(img_exif.datetime, "%Y:%m:%d %H:%M:%S")

    return data


def test_contar_bois_use_case():
    id_imagem = uuid4()

    caminho_imagem = "tests/integracao/images/DJI_0035.JPG"

    data_imagem = pegar_data_imagem(caminho_imagem)

    dados_imagem = cv.imread(caminho_imagem)

    dados_imagem_resized = cv.resize(dados_imagem, (640, 640), interpolation=cv.INTER_AREA)

    imagem = Imagem(id_imagem, -22.45, -45.22, 300, dados_imagem_resized, data_imagem)

    algoritmo_contar_bois = YoloContarBois("ml/modelos/contagem_bois.pt")
    algoritmo_recortar_bebedouro_coucho = YoloIdentificarBebedouroCoucho("ml/modelos/deteccao_coucho_bebedouro.pt")
    algoritmo_identificar_piquete = YoloRecortarImagemPiquete("ml/modelos/deteccao_piquete.pt")

    input_port = ContarBoisPiqueteInputPort([imagem],
                                            algoritmo_contar_bois,
                                            algoritmo_recortar_bebedouro_coucho,
                                            algoritmo_identificar_piquete)

    use_case = ContarBoisPiqueteUseCase(input_port)

    output_port = use_case.run()

    cv.imwrite("tests/integracao/resultados/resultado_use_case_contar_bois.jpg", output_port.contagens[0].imagem.dados)

    assert output_port.contagens[0].qtde_bois_bebendo == 0
    assert output_port.contagens[0].qtde_bois_comendo == 0
    assert output_port.contagens[0].qtde_bois_em_pe == 107
    assert output_port.contagens[0].qtde_bois_deitado == 22
    assert output_port.contagens[0].qtde_total_bois == 129
    assert output_port.contagens[0].data == data_imagem