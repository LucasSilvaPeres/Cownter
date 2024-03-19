from uuid import UUID
from shapely import Polygon

from .voo import Voo


class Piquete:
    def __init__(self,
                 id_piquete: UUID,
                 nome: str,
                 poligono: Polygon,
                 voos: list[Voo]):
        self.id_piquete = id_piquete
        self.nome = nome
        self.voos = voos
        self.poligono = poligono