from ...domain import Imagem, Piquete, Contagem

from tests.utils import verificar_attrs_instancias


def test_instancias_domain():
    instancias = (
        Imagem,
        Piquete,
        Contagem)
    
    verificar_attrs_instancias(instancias)