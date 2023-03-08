FROM rust:1.51-slim-buster
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN mkdir -p /home/node/app

RUN useradd -rm -d /home/node -s /bin/bash -g root -G sudo -u 1001 node && \
	chown -R node /home/node && \
	apt-get update && apt-get -y upgrade && apt-get install -y curl=7.64.0-4+deb10u5  --no-install-recommends && \
	apt-get clean && \
 	rm -rf /var/lib/apt/lists/*

USER node
# Install nvm, node, npm
ARG NVM_DIR="/home/node/.nvm"
ARG NODE_VERSION=16.7.0
RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.38.0/install.sh | bash && \
	. $NVM_DIR/nvm.sh && nvm install $NODE_VERSION --latest-npm
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

WORKDIR /home/node/app

COPY ./package.json ./package.json
COPY ./package-lock.json ./package-lock.json
COPY ./scripts ./scripts
RUN npm ci

COPY . .
USER root
RUN chown -R node /home/node/app
USER node

EXPOSE 3000
CMD ["npm", "run", "start"]