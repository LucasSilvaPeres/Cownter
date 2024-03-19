from unittest.mock import MagicMock

from domain import Contagem


def test_contagem_qtde_total_bois():
    id_contagem = MagicMock()
    data = MagicMock()
    imagem = MagicMock()

    contagem = Contagem(id_contagem, 10, 10, 10, 10, data, imagem)

    assert contagem.qtde_total_bois == 40
