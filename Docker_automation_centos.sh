#! /bin/bash
#https://www.linkedin.com/pulse/ssh-docker-container-centos-yashwanth-medisetti
docker rm -f $(docker ps -qa)
docker rmi -f $(docker images -qa)
echo "Welcome to Docker World"
sleep 2
pub=$(cat $HOME/.ssh/id_rsa.pub)

cat << EOF  > Dockerfile
FROM centos:latest
LABEL maintainer="rakeshece1993@gmail.com"
RUN yum clean all && yum repolist all
RUN yum install openssh openssh-server -y
RUN yum  install passwd net-tools -y

RUN mkdir /var/run/sshd
RUN mkdir /root/.ssh
RUN echo 'root:redhat' |chpasswd

RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

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
	docker run -d --privileged $(tail -n 1 /tmp/data | awk {'print $3'}) /usr/sbin/init
	i=$(( $i + 1 ))
done

docker ps -a | nl

for i in $(docker ps -a | awk '{print $1}' | sed 1d); do docker exec -it $i hostname -i; done
#ssh-keygen

#a=$(cat $HOME/.ssh/id_rsa.pub)




