FROM ruby:2.6.4-stretch

# make Apt non-interactive
RUN echo 'APT::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/90circleci \
  && echo 'DPkg::Options "--force-confnew";' >> /etc/apt/apt.conf.d/90circleci

ENV DEBIAN_FRONTEND=noninteractive

# man directory is missing in some base images
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=863199
RUN apt-get update \
  && mkdir -p /usr/share/man/man1 \
  && apt-get install -y \
    git mercurial xvfb \
    locales libssl-dev sudo openssh-client ca-certificates tar gzip parallel \
    net-tools netcat unzip zip bzip2 gnupg curl wget libsodium-dev mysql-client libsqlite3-dev

# Set timezone to UTC by default
RUN ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime

# Use unicode
RUN locale-gen C.UTF-8 || true
ENV LANG=C.UTF-8

# install jq
RUN JQ_URL="https://circle-downloads.s3.amazonaws.com/circleci-images/cache/linux-amd64/jq-latest" \
  && curl --silent --show-error --location --fail --retry 3 --output /usr/bin/jq $JQ_URL \
  && chmod +x /usr/bin/jq \
  && jq --version

# Install Docker

# Docker.com returns the URL of the latest binary when you hit a directory listing
# We curl this URL and `grep` the version out.
# The output looks like this:

#>    # To install, run the following commands as root:
#>    curl -fsSLO https://download.docker.com/linux/static/stable/x86_64/docker-17.05.0-ce.tgz && tar --strip-components=1 -xvzf docker-17.05.0-ce.tgz -C /usr/local/bin
#>
#>    # Then start docker in daemon mode:
#>    /usr/local/bin/dockerd

RUN set -ex \
  && export DOCKER_VERSION=$(curl --silent --fail --retry 3 https://download.docker.com/linux/static/stable/x86_64/ | grep -o -e 'docker-[.0-9]*-ce\.tgz' | sort -r | head -n 1) \
  && DOCKER_URL="https://download.docker.com/linux/static/stable/x86_64/${DOCKER_VERSION}" \
  && echo Docker URL: $DOCKER_URL \
  && curl --silent --show-error --location --fail --retry 3 --output /tmp/docker.tgz "${DOCKER_URL}" \
  && ls -lha /tmp/docker.tgz \
  && tar -xz -C /tmp -f /tmp/docker.tgz \
  && mv /tmp/docker/* /usr/bin \
  && rm -rf /tmp/docker /tmp/docker.tgz \
  && which docker \
  && (docker version || true)

RUN groupadd --gid 1000 node \
  && useradd --uid 1000 --gid node --shell /bin/bash --create-home node

ENV NODE_VERSION 10.15.3

RUN ARCH= && dpkgArch="$(dpkg --print-architecture)" \
  && case "${dpkgArch##*-}" in \
    amd64) ARCH='x64';; \
    ppc64el) ARCH='ppc64le';; \
    s390x) ARCH='s390x';; \
    arm64) ARCH='arm64';; \
    armhf) ARCH='armv7l';; \
    i386) ARCH='x86';; \
    *) echo "unsupported architecture"; exit 1 ;; \
  esac \
  # gpg keys listed at https://github.com/nodejs/node#release-keys
  && set -ex \
  && for key in \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    77984A986EBC2AA786BC0F66B01FBB92821C587A \
    8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
    4ED778F539E3634C779C87C6D7062848A1AB005C \
    A48C2BEE680E841632CD4E44F07496B3EB3C1762 \
    B9E2F5981AA6E0CD28160D9FF13993A75599653C \
  ; do \
    gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
    gpg --batch --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --batch --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
  done \
  && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH.tar.xz" \
  && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-$ARCH.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -xJf "node-v$NODE_VERSION-linux-$ARCH.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
  && rm "node-v$NODE_VERSION-linux-$ARCH.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs

ENV YARN_VERSION 1.13.0

RUN set -ex \
  && for key in \
    6A010C5166006599AA17F08146C2130DFD2497F5 \
  ; do \
    gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
    gpg --batch --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --batch --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
  done \
  && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
  && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz.asc" \
  && gpg --batch --verify yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
  && mkdir -p /opt \
  && tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/ \
  && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
  && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg \
  && rm yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz


# Basic smoke test
RUN node --version

# docker compose
#RUN COMPOSE_URL="https://circle-downloads.s3.amazonaws.com/circleci-images/cache/linux-amd64/docker-compose-latest" \
  #&& curl --silent --show-error --location --fail --retry 3 --output /usr/bin/docker-compose $COMPOSE_URL \
  #&& chmod +x /usr/bin/docker-compose \
  #&& docker-compose version

# install dockerize
#RUN DOCKERIZE_URL="https://circle-downloads.s3.amazonaws.com/circleci-images/cache/linux-amd64/dockerize-latest.tar.gz" \
  #&& curl --silent --show-error --location --fail --retry 3 --output /tmp/dockerize-linux-amd64.tar.gz $DOCKERIZE_URL \
  #&& tar -C /usr/local/bin -xzvf /tmp/dockerize-linux-amd64.tar.gz \
  #&& rm -rf /tmp/dockerize-linux-amd64.tar.gz \
  #&& dockerize --version

#RUN groupadd --gid 3434 circleci \
  #&& useradd --uid 3434 --gid circleci --shell /bin/bash --create-home circleci \
  #&& echo 'circleci ALL=NOPASSWD: ALL' >> /etc/sudoers.d/50-circleci \
  #&& echo 'Defaults    env_keep += "DEBIAN_FRONTEND"' >> /etc/sudoers.d/env_keep

# BEGIN IMAGE CUSTOMIZATIONS

# END IMAGE CUSTOMIZATIONS

#USER circleci

# ENV NVM_DIR ~/.nvm
#ENV NVM_DIR /usr/local/nvm
#ENV NODE_VERSION v10.16.0

#RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash

#ENV NVM_DIR /root/.nvm
#RUN /bin/bash -c "source $NVM_DIR/nvm.sh && nvm install $NODE_VERSION && nvm use $NODE_VERSION"

#ENV NODE_PATH $NVM_DIR/versions/node/$NODE_VERSION/lib/node_modules
#ENV PATH      $NVM_DIR/versions/node/$NODE_VERSION/bin:$PATH

# RUN curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
#RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
# RUN apt-get install libsodium-dev mysql-client libsqlite3-dev -y

#RUN node -v

#RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add \
  #&& echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  #&& apt-get update \
  #&& apt-get install -y yarn \
  #&& which yarn \
  #&& yarn --version

# Install yarn

#ENV NODE_VERSION v8.12.0

#RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash

#ENV NVM_DIR /root/.nvm
#RUN /bin/bash -c "source $NVM_DIR/nvm.sh && nvm install $NODE_VERSION && nvm use $NODE_VERSION"

#ENV NODE_PATH $NVM_DIR/versions/node/$NODE_VERSION/lib/node_modules
#ENV PATH      $NVM_DIR/versions/node/$NODE_VERSION/bin:$PATH

#RUN apt-get install libsodium-dev mysql-client libsqlite3-dev -y

#RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add \
  #&& echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  #&& apt-get update \
  #&& apt-get install -y yarn \
  #&& which yarn \
  #&& yarn --version

# Install yarn
#RUN apt-get update && apt-get install -y apt-transport-https
#RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
#RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

#RUN apt-get update && apt-get install yarn -y \
  #&& which yarn \
  #&& yarn --version

# install chrome

RUN curl --silent --show-error --location --fail --retry 3 --output /tmp/google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && (sudo dpkg -i /tmp/google-chrome-stable_current_amd64.deb || sudo apt-get -fy install)  \
    && rm -rf /tmp/google-chrome-stable_current_amd64.deb \
    && sudo sed -i 's|HERE/chrome"|HERE/chrome" --disable-setuid-sandbox --no-sandbox|g' \
        "/opt/google/chrome/google-chrome" \
    && google-chrome --version

#RUN CHROME_VERSION="$(google-chrome --version)" \
    #&& export CHROMEDRIVER_RELEASE="$(echo $CHROME_VERSION | sed 's/^Google Chrome //')" && export CHROMEDRIVER_RELEASE=${CHROMEDRIVER_RELEASE%%.*} \
    #&& CHROMEDRIVER_VERSION=$(curl --silent --show-error --location --fail --retry 4 --retry-delay 5 http://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROMEDRIVER_RELEASE}) \
    #&& curl --silent --show-error --location --fail --retry 4 --retry-delay 5 --output /tmp/chromedriver_linux64.zip "http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip" \
    #&& cd /tmp \
    #&& unzip chromedriver_linux64.zip \
    #&& rm -rf chromedriver_linux64.zip \
    #&& sudo mv chromedriver /usr/local/bin/chromedriver \
    #&& sudo chmod +x /usr/local/bin/chromedriver \
    #&& chromedriver --version

ENV DISPLAY :99
RUN printf '#!/bin/sh\nXvfb :99 -screen 0 2560x2560x24 &\nexec "$@"\n' > /tmp/entrypoint \
  && chmod +x /tmp/entrypoint \
        && sudo mv /tmp/entrypoint /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/sh"]
