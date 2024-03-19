from uuid import uuid4

from shapely.geometry import shape

from domain import Piquete


class PiqueteJsonAdapter:
    @staticmethod
    def to_json():
        pass

    @staticmethod
    def from_json(json_data: dict):
        piquete_id = json_data["properties"].get("piquete_id", uuid4())
        poligono = shape(json_data["geometry"])
        nome = json_data["properties"].get("nome")
        contagens = json_data["properties"].get("contagens", [])

        piquete = Piquete(piquete_id, nome, poligono, contagens)

        return piquete
