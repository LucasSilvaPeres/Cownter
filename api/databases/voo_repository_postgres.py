from datetime import datetime

from uuid import UUID, uuid4
from psycopg2 import connect
from psycopg2.errors import UniqueViolation

from domain import Voo, Contagem
from repositories import VooRepository


class VooPiqueteJaCadastrado(Exception):
    pass


class VooRepositoryPostgres(VooRepository):
    def __init__(self, conn_string: str):
        self._conn_string = conn_string
    
    def _conectar(self):
        conexao = connect(self._conn_string)

        return conexao

    def cadastrar_voo(self, voo: Voo, fazenda_id: str, equipe_id: str, temperatura: int, indice_pluviometrico: int):
        with self._conectar() as conexao:
            cursor = conexao.cursor()

            query = """INSERT INTO "Voos" ("Id", "Data", "Fazenda_id", "EquipeId", "Temperatura", "IndicePluviometrico") VALUES (%s, %s, %s, %s, %s, %s)"""

            cursor.execute(query, (str(voo.voo_id), voo.data, fazenda_id, equipe_id, temperatura, indice_pluviometrico))

            conexao.commit()

    def salvar_voo_piquete(self, voo_id: str, piquete_id: str):
        with self._conectar() as conexao:
            cursor = conexao.cursor()
            
            query = """INSERT INTO "PiqueteVoo" ("VoosId", "PiquetesId") VALUES (%s, %s)"""

            try:
                cursor.execute(query, (str(voo_id), str(piquete_id)))

                conexao.commit()
            except UniqueViolation:
                raise VooPiqueteJaCadastrado("A contagem desse voo já foi realizada")


    def existe_voo_data(self, data: datetime):
        with self._conectar() as conexao:

            cursor = conexao.cursor()

            query = """SELECT * FROM "Voos" WHERE Date("Data") = Date(%s)"""

            cursor.execute(query, (data, ))

            resultado = cursor.fetchone()

            return bool(resultado)

    def pegar_voo_data(self, data: datetime):
        with self._conectar() as conexao:

            cursor = conexao.cursor()

            query = """SELECT * FROM "Voos" WHERE Date("Data") = Date(%s)"""

            cursor.execute(query, (data, ))

            resultado = cursor.fetchone()

            return Voo(resultado[1], [], voo_id=resultado[0])
    
    def _listar_contagens_por_voo_id(self, voo_id: UUID) -> list[Contagem]:
        with self._conectar() as conexao:
            cursor = conexao.cursor()

            query = """
                SELECT *
                FROM CONTAGENS c
                INNER JOIN voos_piquetes vp
                ON (vp.id=c.voo_piquete_id)
                WHERE vp.voo_id  = %s"""
            
            cursor.execute(query, (str(voo_id), ))

            resultados = cursor.fetchall()

            contagens: list[Contagem] = []

            for resultado in resultados:
                contagem = Contagem(
                    resultado[0],
                    resultado[1],
                    resultado[2],
                    resultado[3],
                    resultado[4],
                    resultado[5],
                    None)
                
                contagens.append(contagem)
        
            return contagens
        
    def pegar_voo_por_id(self, voo_id: UUID) -> Voo:
        with self._conectar() as conexao:
            cursor = conexao.cursor()

            query = """SELECT * FROM "Voos" WHERE "Id" = %s"""

            cursor.execute(query, (str(voo_id), ))

            resultado = cursor.fetchone()

            contagens = []

            return Voo(resultado[1], contagens, voo_id=resultado[0])