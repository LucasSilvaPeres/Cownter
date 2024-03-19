from unittest import TestCase
from unittest.mock import MagicMock, patch

from databases import Postgres


class PostgresTestCase(TestCase):
    def setUp(self) -> None:
        mock_url = MagicMock()

        self.database = Postgres(mock_url)

    @patch("databases.postgres.psycopg2")
    def test_conectar(self, mock_psycopg2: MagicMock):
        resultado = self.database._conectar()
        
        mock_psycopg2.connect.assert_called_once_with(self.database.url_conexao)

        self.assertEqual(mock_psycopg2.connect(), resultado)

    @patch.object(Postgres, "_conectar")
    @patch("databases.postgres.uuid")
    @patch("databases.postgres.Piquete")
    def test_pegar_piquete(self, mock_piquete: MagicMock, mock_uuid: MagicMock, mock_conectar: MagicMock):
        mock_latitude, mock_longitude = MagicMock(), MagicMock()

        resultado = self.database.pegar_piquete(mock_latitude, mock_longitude)

        mock_conectar.assert_called_once()

        mock_cursor = mock_conectar().cursor()

        query_esperada = """SELECT * FROM piquetes WHERE ST_Contains(poligono, ST_SetSRID(ST_MakePoint(%s, %s), 4326))"""
        
        mock_cursor.execute.assert_called_once_with(query_esperada, (mock_longitude, mock_latitude))

        mock_cursor.fetchone.assert_called_once()

        mock_cursor.close.assert_called_once()
        mock_conectar().close.assert_called_once()

        mock_uuid.UUID.assert_called_once_with(mock_cursor.fetchone()[0])

        mock_piquete.assert_called_once_with(
            mock_uuid.UUID(),
            mock_cursor.fetchone()[1],
            [])
        
        self.assertEqual(mock_piquete(), resultado)

    @patch.object(Postgres, "_conectar")
    @patch("databases.postgres.uuid")
    @patch("databases.postgres.Fazenda")
    def test_pegar_fazenda_por_piquete(self, mock_fazenda: MagicMock, mock_uuid: MagicMock, mock_conectar: MagicMock):
        mock_piquete = MagicMock()

        resultado = self.database.pegar_fazenda_por_piquete(mock_piquete)

        mock_conectar.assert_called_once()

        mock_cursor = mock_conectar().cursor()

        query_esperada = """SELECT fazendas.id, fazendas.nome FROM fazendas INNER JOIN piquetes ON (piquetes.fazenda_id=fazendas.id) WHERE piquetes.id=%s"""

        mock_cursor.execute.assert_called_once_with(query_esperada, (str(mock_piquete.id_piquete), ))

        mock_cursor.fetchone.assert_called_once()

        mock_cursor.close.assert_called_once()
        mock_conectar().close.assert_called_once()

        mock_uuid.UUID.assert_called_once_with(mock_cursor.fetchone()[0])

        mock_fazenda.assert_called_once_with(mock_uuid.UUID(), mock_cursor.fetchone()[1], [])

        self.assertEqual(mock_fazenda(), resultado)

    @patch.object(Postgres, "_conectar")
    def test_salvar_contagem(self, mock_conectar: MagicMock):
        mock_piquete = MagicMock()
        mock_contagem = MagicMock()
        mock_caminho_imagem = MagicMock()

        self.database.salvar_contagem(mock_piquete, mock_contagem, mock_caminho_imagem)

        mock_conectar.assert_called_once()

        mock_cursor = mock_conectar().cursor()

        query_esperada = """INSERT INTO contagens (id, qtde_bois_deitado, qtde_bois_em_pe, qtde_bois_comendo, qtde_bois_bebendo, data, caminho_imagem, piquete_id) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)"""

        mock_cursor.execute.assert_called_once_with(
            query_esperada,
            (
                str(mock_contagem.id_contagem),
                mock_contagem.qtde_bois_deitado,
                mock_contagem.qtde_bois_em_pe,
                mock_contagem.qtde_bois_comendo,
                mock_contagem.qtde_bois_bebendo,
                mock_contagem.data,
                mock_caminho_imagem,
                str(mock_piquete.id_piquete)
            )
        )

        mock_cursor.close.assert_called_once()
        mock_conectar().commit.assert_called_once()
        mock_conectar().close.assert_called_once()
