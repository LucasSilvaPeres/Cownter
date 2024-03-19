from uuid import UUID
from datetime import datetime

from .imagem import Imagem


class Contagem:
    def __init__(self,
                 id_contagem: UUID,
                 qtde_bois_deitado: int,
                 qtde_bois_em_pe: int,
                 qtde_bois_comendo: int,
                 qtde_bois_bebendo: int,
                 data: datetime,
                 imagem: Imagem):
        self.id_contagem = id_contagem
        self.qtde_bois_deitado = qtde_bois_deitado
        self.qtde_bois_em_pe = qtde_bois_em_pe
        self.qtde_bois_comendo = qtde_bois_comendo
        self.qtde_bois_bebendo = qtde_bois_bebendo
        self.data = data
        self.imagem = imagem

    @property
    def qtde_total_bois(self):
        return self.qtde_bois_bebendo +\
               self.qtde_bois_comendo +\
               self.qtde_bois_em_pe +\
               self.qtde_bois_deitado
