import cv2 as cv

import numpy as np
from numpy.typing import ArrayLike

from ultralytics import YOLO

from domain import Imagem
from use_cases.contar_bois_piquete.coucho import Coucho
from use_cases.contar_bois_piquete.bebedouro import Bebedouro


class YoloIdentificarBebedouroCoucho:
    def __init__(self, caminho_modelo: str):
        self.caminho_modelo = caminho_modelo

    def pegar_modelo(self):
        return YOLO(self.caminho_modelo)
    
    def _pegar_contornos(self, mascara: ArrayLike):
        contornos, _ = cv.findContours(mascara, cv.RETR_EXTERNAL, cv.CHAIN_APPROX_SIMPLE)

        return contornos
    
    def identificar_couchos_bebedouros(self, modelo: YOLO, img: Imagem) -> list[Bebedouro | Coucho]:
        resultados = modelo.predict(source=(img.dados, ),
                                    box=False,
                                    hide_labels=True,
                                    hide_conf=True)
        
        resultado = resultados[0]

        mascaras = resultado.masks.cpu().numpy()
        caixas = resultado.boxes

        for mascara, caixa in zip(mascaras, caixas):
            posicao = caixa.boxes[0][-1]
            mascara = mascara.masks.astype(np.uint8)

            classe = Coucho if posicao == 0 else Bebedouro

            contornos = self._pegar_contornos(mascara)

            yield classe(contornos)
