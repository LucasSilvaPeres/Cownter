from uuid import UUID
from abc import ABC, abstractmethod


class FazendaRepository(ABC):
    @abstractmethod
    def pegar_fazenda_por_id(self, fazenda_id: UUID):
        raise NotImplementedError()

    @abstractmethod
    def listar_fazendas(self):
        raise NotImplementedError()
