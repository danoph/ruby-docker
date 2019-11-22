FROM ruby:2.6.4-alpine3.10

RUN echo 'http://dl-cdn.alpinelinux.org/alpine/v3.5/main' >> /etc/apk/repositories \
  && apk add --update --no-cache \
  build-base \
  libsodium-dev \
  nodejs \
  unzip \
  mariadb-client \
  mariadb-dev \
  #mysql-dev \
  sqlite-dev \
  git \
  imagemagick-dev=6.9.6.8-r1 \
  # for nokogiri
  ruby-dev \
  libxml2-dev \
  libxslt-dev \
  pcre-dev \
  libffi-dev \
  zlib \
  zlib-dev \
  libressl \
  libressl-dev \
  yarn
  #wget \
  #gcc \
  #openssl-dev

RUN node -v
RUN convert --version
RUN ruby -v
RUN mysql --version
RUN git --version
# RUN openssl -v

CMD [ "irb" ]
