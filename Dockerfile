FROM ubuntu:14.04

MAINTAINER andrew.replogle@gmail.com

ARG NODE_VERSION=0.10 
ENV REMOTE_REPO=https://github.com/rhiokim/haroopad.git
ENV LOCAL_REPO=/opt/haroopad
ENV MY_USER=haroopad
ENV MY_BRANCH=master

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yqq apt-transport-https \
                                                        ca-certificates \
                                                        curl \
                                                        git \
                                                        supervisor

RUN curl --fail -ssL -o /tmp/setup-nodejs https://deb.nodesource.com/setup_$NODE_VERSION && \
    bash /tmp/setup-nodejs && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq nodejs build-essential && \
    rm -rf /tmp/setup-nodejs

# Need to generate ssh keys and copy them to a .ssh dir in the Dockerfile directory.
COPY .ssh /root/.ssh

RUN chown -R root: /root/.ssh && \
    chmod 700 /root/.ssh && \
    chmod 600 /root/.ssh/id_dsa 

RUN ssh-keyscan -t rsa github.com > ~/.ssh/known_hosts && \
    git clone $REMOTE_REPO $LOCAL_REPO && \
    cd $LOCAL_REPO && \
    npm install -g nodemon gulp-cli

RUN groupadd -r $MY_USER && \
    useradd -r -g $MY_USER $MY_USER && \
    chown -R $MY_USER: $LOCAL_REPO && \
    apt-get --purge -yqq remove dpkg-dev g++ gcc libc6-dev make build-essential && \
    apt-get -yqq autoremove

COPY supervisord.conf /etc/supervisor/conf.d/
COPY entrypoint.sh /

CMD ["/usr/bin/supervisord"]

