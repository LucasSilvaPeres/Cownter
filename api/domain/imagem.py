from uuid import UUID
from datetime import datetime

from numpy.typing import ArrayLike


class Imagem:
    def __init__(self,
                 id_imagem: UUID,
                 latitude: float,
                 longitude: float,
                 altitude: float,
                 dados: ArrayLike,
                 data: datetime):
        self.id_imagem = id_imagem
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.dados = dados
        self.data = data
