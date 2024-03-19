from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, UploadFile, File, Form
from fastapi.responses import JSONResponse

from config import pegar_variaveis_ambiente

from databases import VooRepositoryPostgres, Postgres, PiqueteRepositoryPostgres, ContagemRepositoryPostgres

from controllers import ContarBoisPiqueteController

from services import FilesystemImagemGateway

from use_cases.contar_bois_piquete import BebedouroCouchoiNaoEncontradosException, BoisNaoEncontradosException, ProblemaImagemPiqueteException


router = APIRouter(
    prefix="/voos",
    tags=["voos"],
)

@router.post("/contagens")
async def cadastrar_contagem_voo(
        equipe_id: Annotated[str, Form()],
        temperatura: Annotated[float, Form()],
        indice_pluviometrico: Annotated[float, Form()],
        foto: Annotated[UploadFile, File()]):

    if not equipe_id:
        return JSONResponse({"error": "ID da equipe não foi informado"}, 400)

    variaveis_ambiente = pegar_variaveis_ambiente()

    url_banco = variaveis_ambiente["URL_CONEXAO_POSTGRES"]

    bytes_foto = await foto.read()

    caminho_modelo_contar_bois = "ml/modelos/best_vaca.pt"
    caminho_modelo_identificar_bebedouro_coucho = "ml/modelos/modelosv1/deteccao_coucho_bebedouro.pt"
    caminho_modelo_recortar_imagem_piquete = "ml/modelos/best_fence.pt"

    imagem_gateway = FilesystemImagemGateway()

    banco = Postgres(url_banco)
    voo_repository = VooRepositoryPostgres(url_banco)
    contagem_repository = ContagemRepositoryPostgres(url_banco)
    piquete_repository = PiqueteRepositoryPostgres(url_banco)

    controller = ContarBoisPiqueteController(imagem_gateway,
                                             banco,
                                             voo_repository,
                                             piquete_repository,
                                             contagem_repository,
                                             bytes_foto,
                                             caminho_modelo_contar_bois,
                                             caminho_modelo_identificar_bebedouro_coucho,
                                             caminho_modelo_recortar_imagem_piquete,
                                             equipe_id,
                                             temperatura,
                                             indice_pluviometrico)

    try:
        apresentacao = controller.run()
        return apresentacao

    except BoisNaoEncontradosException as exc:
        return JSONResponse({"error": "Não foi encontrado nenhum boi na imagem enviada"}, 504)
    except ProblemaImagemPiqueteException as exc:
        return JSONResponse({"error": "Não foi possível recortar a imagem enviada"})
    except BebedouroCouchoiNaoEncontradosException as exc:
        return JSONResponse({"error": "Não foi encontrado nenhum coucho nem bebedouro na imagem enviada"}, 504)
    except Exception as exc:
        return JSONResponse({"error": str(exc)}, 500)
