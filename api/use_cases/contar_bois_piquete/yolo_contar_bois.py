from typing import Generator

from ultralytics import YOLO

from use_cases.contar_bois_piquete.boi import Boi

from domain import Imagem


class YoloContarBois:
    def __init__(self, caminho_modelo: str):
        self.caminho_modelo = caminho_modelo

    def pegar_modelo(self):
        return YOLO(self.caminho_modelo)
        
    
    def contar(self, modelo: YOLO, img: Imagem) -> Generator[Boi, None, None]:
        resultados = modelo.predict(source=(img.dados, ),
                                    box=False,
                                    hide_labels=True,
                                    hide_conf=True)
        resultado = resultados[0]

        for boi in resultado:
            estado = "Standing-Cow" if boi.boxes.boxes[0][-1] == 1 else "Lying-Cow"
            caixa = tuple(int(c) for c in boi.boxes.xyxy[0])

            yield Boi(caixa, estado)