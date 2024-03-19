from unittest import TestCase
from unittest.mock import MagicMock, patch, call

from controllers import ContarBoisPiqueteController

from tests.utils import verificar_attrs_instancias


def test_instancias_controllers():
    instancias = (
        ContarBoisPiqueteController,
    )

    verificar_attrs_instancias(instancias)


class ContarBoisPiqueteControllerTestCase(TestCase):
    def setUp(self):
        mock_database = MagicMock()
        mock_arquivos_imagens = MagicMock()
        mock_caminho_modelo_contar_bois = MagicMock()
        mock_modelo_identificar_bebedouro_coucho = MagicMock()
        mock_caminho_modelo_recortar_imagem_piquete = MagicMock()

        self.controller = ContarBoisPiqueteController(mock_database,
                                                      mock_arquivos_imagens,
                                                      mock_caminho_modelo_contar_bois,
                                                      mock_modelo_identificar_bebedouro_coucho,
                                                      mock_caminho_modelo_recortar_imagem_piquete)

    def test_calcular_coord_decimal_s(self):
        mock_coord = (1.1, 1.1, 1.1)
        mock_ref = "S"

        resultado = self.controller._calcular_coord_decimal(mock_coord, mock_ref)

        esperado = -(mock_coord[0] + mock_coord[1] / 60 + mock_coord[2] / 3600)

        self.assertEqual(resultado, esperado)

    def test_calcular_coord_decimal_n(self):
        mock_coord = (1.1, 1.1, 1.1)
        mock_ref = "N"

        resultado = self.controller._calcular_coord_decimal(mock_coord, mock_ref)

        esperado = (mock_coord[0] + mock_coord[1] / 60 + mock_coord[2] / 3600)

        self.assertEqual(resultado, esperado)

    @patch.object(ContarBoisPiqueteController, "_instanciar_imagem")
    def test_instanciar_imagens(self, mock_instanciar_imagem: MagicMock):
        mock_arquivo_imagem1 = MagicMock()
        mock_arquivo_imagem2 = MagicMock()

        mock_arquivos_imagens = [mock_arquivo_imagem1, mock_arquivo_imagem2]
    
        self.controller.arquivos_imagens = mock_arquivos_imagens

        resultado = self.controller._instanciar_imagens()

        calls_instanciar_imagens = [
            call(mock_arquivo_imagem1),
            call(mock_arquivo_imagem2)
        ]

        mock_instanciar_imagem.assert_has_calls(calls_instanciar_imagens)

        esperado = [mock_instanciar_imagem(), mock_instanciar_imagem()]

        self.assertEqual(esperado, resultado)

    @patch("controllers.contar_bois_piquete_controller.uuid4")
    @patch("controllers.contar_bois_piquete_controller.np")
    @patch("controllers.contar_bois_piquete_controller.cv")
    @patch("controllers.contar_bois_piquete_controller.Imagem")
    @patch.object(ContarBoisPiqueteController, "_extrair_informacoes_exif_imagem")
    def test_instanciar_imagem(self,
                                mock_extrair_info_exif: MagicMock,
                                mock_imagem: MagicMock,
                                mock_cv: MagicMock,
                                mock_np: MagicMock,
                                mock_uuid4: MagicMock):
        mock_arquivo_imagem = MagicMock()

        mock_latitude, mock_longitude, mock_altitude, mock_data = MagicMock(), MagicMock(), MagicMock(), MagicMock()

        mock_extrair_info_exif.return_value = (mock_latitude, mock_longitude, mock_altitude, mock_data)

        resultado = self.controller._instanciar_imagem(mock_arquivo_imagem)

        mock_uuid4.assert_called_once()

        mock_np.frombuffer.assert_called_once_with(mock_arquivo_imagem, mock_np.uint8)

        mock_cv.imdecode.assert_called_once_with(mock_np.frombuffer(), -1)

        mock_imagem.assert_called_once_with(mock_uuid4(), mock_latitude, mock_longitude, mock_altitude, mock_cv.imdecode(), mock_data)

        self.assertEqual(mock_imagem(), resultado)

    @patch("controllers.contar_bois_piquete_controller.ImageEXIF")
    @patch.object(ContarBoisPiqueteController, "_calcular_coord_decimal")
    @patch("controllers.contar_bois_piquete_controller.datetime")
    def test_extrair_informacoes_exif_imagem(self,
                                             mock_datetime: MagicMock,
                                             mock_calcular_coord_decimal: MagicMock,
                                             mock_imagem_exif: MagicMock):

        mock_arquivo_imagem = MagicMock()

        resultado = self.controller._extrair_informacoes_exif_imagem(mock_arquivo_imagem)

        mock_imagem_exif.assert_called_once_with(mock_arquivo_imagem)

        calls_calcular_coord_decimal = (
            call(mock_imagem_exif().gps_latitude, mock_imagem_exif().gps_latitude_ref),
            call(mock_imagem_exif().gps_longitude, mock_imagem_exif().gps_longitude_ref))
        
        mock_calcular_coord_decimal.assert_has_calls(calls_calcular_coord_decimal)

        mock_datetime.strptime.assert_called_once_with(mock_imagem_exif().datetime, "%Y:%m:%d %H:%M:%S")

        esperado = (mock_calcular_coord_decimal(), mock_calcular_coord_decimal(), mock_imagem_exif().gps_altitude, mock_datetime.strptime())

        self.assertEqual(resultado, esperado)

    @patch("controllers.contar_bois_piquete_controller.datetime")
    def test_criar_caminho_imagem(self, mock_datetime: MagicMock):
        mock_nome_fazenda = MagicMock()
        mock_nome_piquete = MagicMock()
        mock_data_imagem = MagicMock()

        resultado = self.controller._criar_caminho_imagem(mock_nome_fazenda,
                                                          mock_nome_piquete,
                                                          mock_data_imagem)

        mock_nome_fazenda.lower.assert_called_once()
        mock_nome_fazenda.lower().replace.assert_called_once_with(" ", "_")

        mock_nome_fazenda_corrigido = mock_nome_fazenda.lower().replace()
        
        mock_nome_piquete.lower.assert_called_once()
        mock_nome_piquete.lower().replace.assert_called_once_with(" ", "_")
        mock_nome_piquete.lower().replace().replace.assert_called_once_with(":", "")

        mock_nome_piquete_corrigido = mock_nome_piquete.lower().replace().replace()

        mock_datetime.strftime.assert_called_once_with(mock_data_imagem, "%Y%m%d_%H%M%S")

        mock_data_formatada = mock_datetime.strftime()

        esperado = f"resultados/{mock_nome_fazenda_corrigido}/{mock_nome_piquete_corrigido}/{mock_data_formatada}.jpg"

        self.assertEqual(esperado, resultado)

    @patch.object(ContarBoisPiqueteController, "_criar_caminho_imagem")
    def test_salvar_contagem(self, mock_criar_caminho_imagem: MagicMock):
        mock_contagem = MagicMock()

        self.controller._salvar_contagem(mock_contagem)

        self.controller.database_gateway.pegar_piquete.assert_called_once_with(
            mock_contagem.imagem.latitude, mock_contagem.imagem.longitude)
        
        mock_piquete = self.controller.database_gateway.pegar_piquete()

        self.controller.database_gateway.pegar_fazenda_por_piquete.assert_called_once_with(
            mock_piquete)

        mock_fazenda = self.controller.database_gateway.pegar_fazenda_por_piquete()
        
        mock_criar_caminho_imagem.assert_called_once_with(mock_fazenda.nome, mock_piquete.nome, mock_contagem.imagem.data)

        self.controller.database_gateway.salvar_contagem.assert_called_once_with(mock_piquete, mock_contagem, mock_criar_caminho_imagem())

    @patch.object(ContarBoisPiqueteController, "_salvar_contagem")
    def test_salvar_contagens(self, mock_salvar_contagem: MagicMock):
        mock_contagem1 = MagicMock()
        mock_contagem2 = MagicMock()

        mock_contagens = [mock_contagem1, mock_contagem2]

        self.controller._salvar_contagens(mock_contagens)

        calls_salvar_contagem = [
            call(mock_contagem1),
            call(mock_contagem2)]
        
        mock_salvar_contagem.assert_has_calls(calls_salvar_contagem)

    @patch("controllers.contar_bois_piquete_controller.ContarBoisPiqueteInputPort")
    @patch("controllers.contar_bois_piquete_controller.ContarBoisPiqueteUseCase")
    @patch("controllers.contar_bois_piquete_controller.ContarBoisPiquetePresenter")
    @patch("controllers.contar_bois_piquete_controller.YoloContarBois")
    @patch("controllers.contar_bois_piquete_controller.YoloIdentificarBebedouroCoucho")
    @patch("controllers.contar_bois_piquete_controller.YoloRecortarImagemPiquete")
    @patch.object(ContarBoisPiqueteController, "_instanciar_imagens")
    @patch.object(ContarBoisPiqueteController, "_criar_caminho_imagem")
    @patch.object(ContarBoisPiqueteController, "_salvar_contagens")
    def test_run(self,
                 mock_salvar_contagens: MagicMock,
                 mock_criar_caminho_imagem: MagicMock,
                 mock_instanciar_imagens: MagicMock,
                 mock_recortar_imagem_piquete: MagicMock,
                 mock_identificar_bebedouro_coucho: MagicMock,
                 mock_contar_bois: MagicMock,
                 mock_presenter: MagicMock,
                 mock_use_case: MagicMock,
                 mock_input_port: MagicMock):

        resultado = self.controller.run()

        mock_instanciar_imagens.assert_called_once()

        mock_contar_bois.assert_called_once_with(self.controller.caminho_modelo_contar_bois)

        mock_recortar_imagem_piquete.assert_called_once_with(
            self.controller.caminho_modelo_recortar_imagem_piquete)

        mock_identificar_bebedouro_coucho.assert_called_once_with(
            self.controller.caminho_modelo_identificar_bebedouro_coucho)
        
        mock_input_port.assert_called_once_with(mock_instanciar_imagens(),
                                                mock_contar_bois(),
                                                mock_identificar_bebedouro_coucho(),
                                                mock_recortar_imagem_piquete())
        
        mock_use_case.assert_called_once_with(mock_input_port())

        mock_use_case().run.assert_called_once()

        mock_salvar_contagens.assert_called_once_with(mock_use_case().run().contagens)
        
        mock_presenter.assert_called_once_with(mock_use_case().run())

        mock_presenter().present.assert_called_once()

        self.assertEqual(mock_presenter().present(), resultado)
