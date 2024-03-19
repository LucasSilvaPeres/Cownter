#!/bin/bash

# Replace with the path to your photo and the FastAPI server URL
PHOTO_PATH="tests/integracao/images/foto_88.JPG"
FASTAPI_SERVER="http://127.0.0.1:8000"
EQUIPE_ID="074c0b0e-a961-4c52-bac3-d647f54170c1"
TEMPERATURA=36
INDICE_PLUVIOMETRICO=200

curl -sS -X POST "${FASTAPI_SERVER}/voos/contagens?equipe_id=074c0b0e-a961-4c52-bac3-d647f54170c1&temperatura=36&indice_pluviometrico=200" -H "Content-Type: multipart/form-data" -F "foto=@${PHOTO_PATH}" -F "temperatura=$TEMPERATURA" -F "indice_pluviometrico=$INDICE_PLUVIOMETRICO" -F "equipe_id=$EQUIPE_ID"
