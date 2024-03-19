from uuid import UUID

from .piquete import Piquete


class Fazenda:
    def __init__(self, id_fazenda: UUID, nome: str, piquetes: list[Piquete]):
        self.id_fazenda = id_fazenda
        self.nome = nome
        self.piquetes = piquetes
