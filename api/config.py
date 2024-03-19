import os

from dotenv import load_dotenv


def pegar_variaveis_ambiente() -> dict[str, str]:
    variaveis = {
        "API_CLIENT_URL": "",
        "URL_CONEXAO_POSTGRES": ""
    }

    load_dotenv(override=False)
        
    for nome_variavel in variaveis.keys():
        variaveis[nome_variavel] = os.environ.get(nome_variavel)

    return variaveis
