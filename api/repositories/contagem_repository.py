from uuid import UUID
from datetime import datetime
from abc import ABC, abstractmethod

from domain import Contagem, Piquete, Voo


class ContagemRepository(ABC):
    @abstractmethod
    def salvar_contagem(self, contagem: Contagem, caminho_imagem: str, voo_id: UUID, piquete_id: UUID, fazenda_id: UUID):
        raise NotImplementedError()
    
    @abstractmethod
    def get_voo_piquete_id(self, piquete: Piquete, voo: Voo):
        raise NotImplementedError()

    @abstractmethod
    def existe_contagem_data(self, data: datetime) -> bool:
        raise NotImplementedError()

    @abstractmethod
    def get_caminho_imagem_contagem(self, contagem_id: str) -> str:
        raise NotImplementedError()
