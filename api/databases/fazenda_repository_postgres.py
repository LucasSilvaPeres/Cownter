from uuid import UUID
from psycopg2 import connect
from datetime import datetime

from domain import Fazenda, Contagem, Piquete, Voo


class FazendaRepositoryPostgres():
    def __init__(self, conn_string: str):
        self._conn_string = conn_string

    def _conectar(self):
        conexao = connect(self._conn_string)

        return conexao
    
    def _listar_contagens_por_piquete_id(self, piquete_id: str):
        with self._conectar() as conexao:
            cursor = conexao.cursor()

            query = """SELECT c.* FROM contagens c 
                       INNER JOIN piquetes p ON (p.id=c.piquete_id)
                       WHERE p.id = %s"""
            
            cursor.execute(query, (piquete_id, ))

            resultados = cursor.fetchall()

            contagens = [
                Contagem(
                    UUID(resultado[0]),
                    resultado[1],
                    resultado[2],
                    resultado[3],
                    resultado[4],
                    resultado[5],
                    None)
                for resultado in resultados]
            
            return contagens
        
    def _listar_contagens_por_voo_piquete_id(self, voo_piquete_id: str) -> list[Contagem]:
        with self._conectar() as conexao:
            cursor = conexao.cursor()

            query = """SELECT c.* FROM contagens c
                       WHERE voo_piquete_id = %s"""
            
            cursor.execute(query, (voo_piquete_id, ))

            resultados = cursor.fetchall()

            contagens = [
                Contagem(
                    UUID(resultado[0]),
                    resultado[1],
                    resultado[2],
                    resultado[3],
                    resultado[4],
                    resultado[5],
                    None
                ) for resultado in resultados
            ]

            return contagens
        
    def _listar_voos_por_piquete_id(self, piquete_id: str) -> list[Voo]:
        voos = []

        with self._conectar() as conexao:
            cursor = conexao.cursor()

            query = """
                SELECT vp.id, v.* FROM voos_piquetes vp
                INNER JOIN voos v ON(v.id=vp.voo_id)
                WHERE vp.piquete_id = %s
                ORDER BY v.data
            """

            cursor.execute(query, (piquete_id, ))

            resultados = cursor.fetchall()

            for resultado in resultados:
                contagens = self._listar_contagens_por_voo_piquete_id(resultado[0])

                voo = Voo(
                    resultado[2],
                    contagens,
                    voo_id=UUID(resultado[1]))

                voos.append(voo)

            return voos

    def _listar_piquetes_por_fazenda_id(self, fazenda_id: str):
        piquetes = []
    
        with self._conectar() as conexao:
            cursor = conexao.cursor()

            query = """
                SELECT piquetes.* FROM piquetes
                INNER JOIN fazendas
                ON (fazendas.id=piquetes.fazenda_id)
                WHERE fazenda_id = %s
            """

            cursor.execute(query, (fazenda_id, ))

            resultados = cursor.fetchall()

            for resultado in resultados:
                voos = self._listar_voos_por_piquete_id(resultado[0])

                if not voos:
                    continue

                piquete = Piquete(UUID(resultado[0]), resultado[1], None, voos)

                piquetes.append(piquete)

            return piquetes

    def pegar_fazenda_por_id(self, fazenda_id: UUID):
        fazenda_id = str(fazenda_id)

        with self._conectar() as conexao:
            cursor = conexao.cursor()

            query = """SELECT * FROM fazendas WHERE id = %s"""

            cursor.execute(query, (fazenda_id, ))

            resultado = cursor.fetchone()

            piquetes = self._listar_piquetes_por_fazenda_id(fazenda_id)

            fazenda = Fazenda(UUID(resultado[0]), resultado[1], piquetes)

            return fazenda
