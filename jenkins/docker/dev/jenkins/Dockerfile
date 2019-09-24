FROM jenkins/jenkins:lts

# Suppress apt installation warnings
ENV DEBIAN_FRONTEND=noninteractive

# Change to root user
USER root

ENV TZ=Etc/UTC
RUN set -x
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
RUN apt-get update -y
RUN apt-get install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends apt-utils
RUN apt-get install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends apt-transport-https
RUN apt-get install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends ca-certificates
RUN apt-get install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends curl
RUN apt-get install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends gnupg2
RUN apt-get install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends file
RUN apt-get install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends software-properties-common
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN echo "does the fingerprint of next command matches 9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88"

# Used to set the docker group ID
# Set to 996 by default, which is the group ID used by AWS Linux ECS Instance
ARG DOCKER_GID

# Create Docker Group with GID
# Set default value of 996 if DOCKER_GID set to blank string by Docker Compose
RUN groupadd -g ${DOCKER_GID:-996} docker

# Install base packages
RUN apt-get update -y && \
    apt-get install apt-transport-https curl python-dev python-setuptools gcc make libssl-dev vim -y && \
    easy_install pip

# Install Docker Compose
RUN pip install docker-compose && \
    pip install ansible boto boto3

# Install Docker Engine
#RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D && \
RUN apt-key fingerprint 0EBFCD88
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
RUN apt-get update -y
RUN apt-get install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends docker-ce
#RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys F76221572C52609D
RUN echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | tee /etc/apt/sources.list.d/docker.list
RUN usermod -aG docker jenkins
RUN usermod -aG users jenkins

# Change to jenkins user
USER jenkins

# Add Jenkins plugins
COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt