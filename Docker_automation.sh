#! /bin/bash

echo "Welcome to Docker World"
sleep 2
pub=$(cat $HOME/.ssh/id_rsa.pub)

cat << EOF  > Dockerfile
FROM ubuntu:latest
MAINTAINER Rakesh Kumar "<rakeshece1993@gmail.com>"
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update

RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN mkdir /root/.ssh
RUN echo 'root:redhat' |chpasswd

RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 22

CMD    ["/usr/sbin/sshd", "-D"]
EOF
echo "ENV _K002_=\"$pub\"" >> Dockerfile 
echo "We are Going to Create your one Master images:"
echo "Give any name format [repo_name/name:tag]:"
read dada
docker build - < Dockerfile > /tmp/data

docker tag $(tail -n 1 /tmp/data | awk {'print $3'}) $dada

echo "How many Containers do you want to run: " 
read con
i=1
while [ $i -le $con ]
do
	docker run -dit $(tail -n 1 /tmp/data | awk {'print $3'})
	i=$(( $i + 1 ))
done

docker ps -a | nl

#ssh-keygen

#a=$(cat $HOME/.ssh/id_rsa.pub)




