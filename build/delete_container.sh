sudo docker stop $(docker ps -aq)
sudo docker rm $(docker ps -aq)
sudo docker rmi -f $(docker images -q)

