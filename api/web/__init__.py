from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .routers import voos


origins = ["*"]
app = FastAPI()


app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)

app.include_router(voos.router)

# @routes.get("/healthcheck")
# async def healthcheck():
#     return {"status": "OK"}


__all__ = (
    "app",
)
