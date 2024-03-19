import cv2 as cv
import numpy as np
from numpy.typing import ArrayLike

from ultralytics import YOLO
from ultralytics.yolo.engine.results import Results

from domain import Imagem


class YoloRecortarImagemPiquete:
    def __init__(self, caminho_modelo: str):
        self.caminho_modelo = caminho_modelo

    def pegar_modelo(self):
        return YOLO(self.caminho_modelo)

    def _selecionar_resultado(self, resultados: Results):
        resultado = resultados[0]

        return resultado

    def _detectar_mascara_piquete(self, modelo: YOLO, img: ArrayLike):
        resultados = modelo.predict(source=(img, ),
                                    box=False,
                                    hide_labels=True,
                                    hide_conf=True)
        
        resultado = self._selecionar_resultado(resultados)
        
        mascara = resultado.masks.masks[0].cpu().numpy().astype(np.uint8)

        return mascara

    def recortar_imagem_piquete(self, modelo: YOLO, img: Imagem):
        mascara = self._detectar_mascara_piquete(modelo, img.dados)

        return cv.bitwise_and(img.dados, img.dados, mask=mascara)
