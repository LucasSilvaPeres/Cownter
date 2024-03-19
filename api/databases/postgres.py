import psycopg2
import uuid

from domain import Piquete, Contagem, Fazenda, Voo
from gateways import DatabaseGateway


class Postgres(DatabaseGateway):
    def __init__(self, url_conexao: str):
        self.url_conexao = url_conexao

    def _conectar(self):
        conexao = psycopg2.connect(self.url_conexao)
        return conexao

    def pegar_piquete(self, latitude: float, longitude: float):
        conexao = self._conectar()

        cursor = conexao.cursor()

        query = """SELECT * FROM "Piquetes" WHERE ST_Contains("Poligono", ST_SetSRID(ST_MakePoint(%s, %s), 4326))"""

        cursor.execute(query, (longitude, latitude))

        resultado = cursor.fetchone()

        cursor.close()
        conexao.close()

        piquete_id = uuid.UUID(resultado[0])

        return Piquete(piquete_id, resultado[1], [], [])

    def pegar_fazenda_por_piquete(self, piquete: Piquete):
        conexao = self._conectar()

        cursor = conexao.cursor()

        query = """SELECT "Fazendas"."Id", "Fazendas"."Nome" FROM "Fazendas" INNER JOIN "Piquetes" ON ("Piquetes"."FazendaId"="Fazendas"."Id") WHERE "Piquetes"."Id"=%s"""

        cursor.execute(query, (str(piquete.id_piquete), ))

        resultado = cursor.fetchone()

        cursor.close()
        conexao.close()

        id_fazenda = uuid.UUID(resultado[0])

        return Fazenda(id_fazenda, resultado[1], [])
    
    def salvar_contagem(self, piquete: Piquete, contagem: Contagem, caminho_imagem: str, voo: Voo, fazenda: Fazenda):
        conexao = self._conectar()

        cursor = conexao.cursor()

        query = """INSERT INTO "Contagens" ("Id", "Deitados", "EmPe", "Comendo", "Bebendo", "Data", "Imagem", "PiqueteId", "VooId", "FazendaId") VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)"""

        cursor.execute(query, (
            str(contagem.id_contagem),
            contagem.qtde_bois_deitado,
            contagem.qtde_bois_em_pe,
            contagem.qtde_bois_comendo,
            contagem.qtde_bois_bebendo,
            contagem.data,
            caminho_imagem,
            str(piquete.id_piquete),
            str(voo.voo_id),
            str(fazenda.id_fazenda)))

        cursor.close()
        conexao.commit()
        conexao.close()
