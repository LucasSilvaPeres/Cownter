from uuid import UUID
from datetime import datetime
from psycopg2 import connect


from domain import Contagem, Piquete, Voo
from repositories import ContagemRepository


class ContagemRepositoryPostgres(ContagemRepository):
    def __init__(self, conn_string: str):
        self._conn_string = conn_string
    
    def _conectar(self):
        conexao = connect(self._conn_string)

        return conexao
    
    def salvar_contagem(self, contagem: Contagem, caminho_imagem: str, voo_id: UUID, piquete_id: UUID, fazenda_id: UUID):

        if not self.existe_contagem_data(contagem.data):
            with self._conectar() as conexao:
                cursor = conexao.cursor()

                query = """INSERT INTO contagens
                    ("Id", "Deitados", "EmPe", "Comendo", "Bebendo", "Data", "Imagem", "VooId", "PiqueteId", "FazendaId")
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"""

                cursor.execute(query, (
                    str(contagem.id_contagem),
                    contagem.qtde_bois_deitado,
                    contagem.qtde_bois_em_pe,
                    contagem.qtde_bois_comendo,
                    contagem.qtde_bois_bebendo,
                    contagem.data,
                    caminho_imagem,
                    str(voo_id),
                    str(piquete_id),
                    str(fazenda_id)))

                conexao.commit()

    def get_voo_piquete_id(self, piquete: Piquete, voo: Voo) -> str:
        with self._conectar() as conexao:
            cursor = conexao.cursor()

            query = """
                SELECT id FROM voos_piquetes
                WHERE piquete_id = %s AND voo_id = %s
            """

            cursor.execute(query, (str(piquete.id_piquete), str(voo.voo_id)))

            resultado = cursor.fetchone()

            return resultado[0]
        
    def existe_contagem_data(self, data: datetime):
        with self._conectar() as conexao:
            cursor = conexao.cursor()

            query = """
                SELECT * FROM "Contagens"
                WHERE "Data" = %s
            """

            cursor.execute(query, (data, ))

            resultados = cursor.fetchall()

            return len(resultados) > 0

    def get_caminho_imagem_contagem(self, contagem_id: str) -> str:
        with self._conectar() as conexao:
            cursor = conexao.cursor()

            query = """SELECT caminho_imagem FROM contagens where id = %s"""

            cursor.execute(query, (contagem_id, ))

            resultado = cursor.fetchone()

            return resultado[0]
