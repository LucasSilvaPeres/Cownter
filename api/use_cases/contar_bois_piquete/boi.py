from typing import Tuple


class Boi:
    def __init__(self, caixa: Tuple[int, int, int, int], estado: str):
        self.caixa = caixa
        self.estado = estado
    
    def alterar_estado(self, nova_estado: str):
        self.estado = nova_estado