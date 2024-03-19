from datetime import datetime
from uuid import UUID
from abc import ABC, abstractmethod

from domain import Voo


class VooRepository(ABC):
    @abstractmethod
    def cadastrar_voo(self, voo: Voo, fazenda_id: str, equipe_id: str, temperatura: int, indice_pluviometrico: int):
        raise NotImplementedError()

    @abstractmethod
    def salvar_voo_piquete(self, voo_id: str, piquete_id: str):
        raise NotImplementedError()

    @abstractmethod
    def existe_voo_data(self, data: datetime):
        raise NotImplementedError()
    
    @abstractmethod
    def pegar_voo_data(self, data: datetime):
        raise NotImplementedError()

    @abstractmethod
    def pegar_voo_por_id(self, voo_id: UUID) -> Voo:
        raise NotImplementedError()
