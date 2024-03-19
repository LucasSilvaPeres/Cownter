from abc import ABC, abstractmethod

from domain import Imagem


class ImagemGateway(ABC):
    @abstractmethod
    def salvar_imagem(self, imagem: Imagem, caminho_imagem: str):
        raise NotImplementedError()

