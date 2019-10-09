#Start with current nginx
FROM nginx:latest
#Update package manager and install git
RUN apt-get update && apt-get install -y \
        git\
        curl\
        vim\
        systemd\
        systemd-container\
	net-tools\
	procps\
	sudo\
	iproute2\
	kmod\
	iptables
#Clean the html root dir
RUN rm -R /usr/share/nginx/html
#Clone pacman app from git
COPY . /usr/share/nginx/html
#Modify files for web serving
RUN chmod -R 755 /usr/share/nginx/html/*
RUN chown -R www-data /usr/share/nginx/html/*
COPY octoshield/octoshield.sh /home/docker/script/
COPY octoshield/config.yml home/docker/script/
RUN chmod 777 /home/docker/script/octoshield.sh
#ENTRYPOINT /home/docker/script/octoshield.sh

#
#USAGE:
# docker run --name pacman -d -p 8080:80 pacman
