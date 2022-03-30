# Dockerfile for Java App
git clone url
cd devopstraning
## Install docker
cd docker
docker build -t javapp .
docker images
docker run -itd -p 8080:8080 javapp
docker ps
Open brower:
http://machineipaddress:8080

