from unittest import TestCase
from unittest.mock import MagicMock

from ...tests.utils import verificar_attrs_instancias

from presenters import ContarBoisPiquetePresenter


def test_instancias_presenters():
    instancias = (
        ContarBoisPiquetePresenter,
    )

    verificar_attrs_instancias(instancias)


class ContarBoisPiquetePresenterTestCase(TestCase):
    def setUp(self):
        mock_output_port = MagicMock()

        self.presenter = ContarBoisPiquetePresenter(mock_output_port)

    def test_present(self):
        mock_contagem_1 = MagicMock()
        mock_contagem_2 = MagicMock()

        mock_contagens = [mock_contagem_1, mock_contagem_2]

        self.presenter.output_port.contagens = mock_contagens
    
        resultado = self.presenter.present()

        esperado = [
            {
                "Bois em pé": mock_contagem.qtde_bois_em_pe,
                "Bois deitados": mock_contagem.qtde_bois_deitado,
                "Bois comendo": mock_contagem.qtde_bois_comendo,
                "Bois bebendo": mock_contagem.qtde_bois_bebendo,
                "Qtde de bois": mock_contagem.qtde_total_bois}
            for mock_contagem in mock_contagens]
        
        self.assertEqual(esperado, resultado)
