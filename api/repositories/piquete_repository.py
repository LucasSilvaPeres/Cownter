from abc import ABC, abstractmethod

from typing import List

from domain import Piquete


class PiqueteRepository(ABC):
    @abstractmethod
    def salvar_piquetes(self, piquetes: List[Piquete], fazenda_id: str):
        raise NotImplementedError()

    @abstractmethod
    def pegar_piquete_por_latlng(self, lat: float, lng: float):
        raise NotImplementedError()
