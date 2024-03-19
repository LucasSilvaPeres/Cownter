from uuid import UUID
from typing import List

from psycopg2 import connect

from domain import Piquete
from repositories import FazendaRepository, PiqueteRepository


class PiqueteRepositoryPostgres(PiqueteRepository):
    def __init__(self, conn_string: str):
        self.conn_string = conn_string

    def _conectar(self):
        conexao = connect(self.conn_string)

        return conexao
    
    def salvar_piquetes(self, piquetes: List[Piquete], fazenda_id: str) -> List[Piquete]:
        with self._conectar() as conexao:
            cursor = conexao.cursor()
            query = """INSERT INTO piquetes (id, nome, poligono, fazenda_id) VALUES (%s, %s, %s, %s)"""
            cursor.executemany(query,
                               [(str(piquete.id_piquete), piquete.nome, piquete.poligono.wkb, fazenda_id)
                                for piquete in piquetes])
            conexao.commit()

    def pegar_piquete_por_latlng(self, lat: float, lng: float):
        with self._conectar() as conexao:
            cursor = conexao.cursor()

            query = """SELECT * FROM "Piquetes" WHERE ST_Contains("Poligono", ST_SetSRID(ST_MakePoint(%s, %s), 4326))"""

            cursor.execute(query, (lng, lat))

            resultado = cursor.fetchone()

            piquete_id = UUID(resultado[0])

            return Piquete(piquete_id, resultado[1], [], [])
