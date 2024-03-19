from datetime import datetime

from uuid import UUID, uuid4

from .contagem import Contagem


class Voo:
    def __init__(self, data: datetime, contagens: list[Contagem], voo_id: None | UUID = None):
        self.voo_id = voo_id or uuid4()
        self.contagens = contagens
        self.data = data
