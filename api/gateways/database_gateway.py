from abc import ABC, abstractmethod

from domain import Contagem, Piquete, Fazenda, Voo


class DatabaseGateway(ABC):
    @abstractmethod
    def salvar_contagem(self, piquete: Piquete, contagem: Contagem, caminho_imagem: str, voo: Voo, fazenda: Fazenda):
        raise NotImplementedError()
    
    @abstractmethod
    def pegar_fazenda_por_piquete(self, piquete: Piquete) -> Fazenda:
        raise NotImplementedError()

    @abstractmethod
    def pegar_piquete(self, latitude: float, longitude: float) -> Piquete:
        raise NotImplementedError()
