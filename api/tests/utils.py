from typing import List
from unittest.mock import MagicMock


def verificar_attrs_instancias(instancias: List[object]):
    for instancia in instancias:
        parametros = instancia.__init__.__annotations__
        parametros_mockados = {parametro: MagicMock()
                               for parametro in parametros}
        objeto = instancia(**parametros_mockados)

        for nome, valor in parametros_mockados.items():
            valor_parametro = getattr(objeto, nome)

            assert valor == valor_parametro
