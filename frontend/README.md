#builda a imagem
docker build -t cownter_frontend .

#executa a imagem (local)
docker run -d -p 8080:80 --name cownter_frontend cownter_frontend

#tagueia a imagem para enviar para o repo
docker tag cownter_frontend  southamerica-east1-docker.pkg.dev/cownter/cownterfrontend/cownter_frontend:latest

#envia a imagem
docker push  southamerica-east1-docker.pkg.dev/cownter/cownterfrontend/cownter_frontend

#baixa a imagem (servidor)
docker pull  southamerica-east1-docker.pkg.dev/cownter/cownterfrontend/cownter_frontend:latest

#executa a imagem --restart unless-stopped
docker run -d --restart unless-stopped -p 80:80 --name cownter_frontend  southamerica-east1-docker.pkg.dev/cownter/cownterfrontend/cownter_frontend

acessar via ssh
gcloud compute ssh --zone "us-central1-a" "cownter-01" --project "cownter"


docker build .

docker stop 

docker run image

sudo docker build -t cownter-front .
docker run -d --restart unless-stopped -p 5173:80 cownterfront
docker logs -f cownterfront

#logs api
docker logs -f cownter-api
