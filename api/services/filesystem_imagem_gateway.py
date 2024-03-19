from os import path, mkdir

from domain import Imagem
from gateways import ImagemGateway

import cv2


class FilesystemImagemGateway(ImagemGateway):
    
    def salvar_imagem(self, imagem: Imagem, caminho_imagem: str):
        presu, nfaz, npiq, nimg = caminho_imagem.split("/")

        if not path.exists(path.join(presu, nfaz)):
            mkdir(path.join(presu, nfaz))

        if not path.exists(path.join(presu, nfaz, npiq)):
            mkdir(path.join(presu, nfaz, npiq))

        cv2.imwrite(caminho_imagem, imagem.dados)

    def get_bytes_imagem(self, caminho_imagem: str) -> bytes:
        with open(caminho_imagem, mode="rb") as arquivo:
            return arquivo.read()
