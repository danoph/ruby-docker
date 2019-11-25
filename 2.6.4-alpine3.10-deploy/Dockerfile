FROM ruby:2.6.4-alpine3.10

RUN echo 'http://dl-cdn.alpinelinux.org/alpine/v3.5/main' >> /etc/apk/repositories \
  && apk add --update --no-cache \
  nginx \
  nodejs \
  curl \
  vim \
  mysql-client \
  openssl \
  tzdata \
  libsodium-dev \
  mariadb-dev \
  unzip \
  zip \
  sqlite-dev \
  imagemagick-dev=6.9.6.8-r1 \
  # for wkhtmltopdf
  libgcc libstdc++ libx11 glib libxrender libxext libintl \
  ttf-dejavu ttf-droid ttf-freefont ttf-liberation ttf-ubuntu-font-family

  #imagemagick-dev \
  #imagemagick

  #imagemagick-dev=7.0.8.58-r0
  # for nokogiri
  #ruby-dev \
  #libxml2-dev \
  #libxslt-dev \
  #pcre-dev \
  #libffi-dev \
  #zlib \
  #zlib-dev \
  #libressl \
  #libressl-dev \
  #yarn

COPY --from=madnight/alpine-wkhtmltopdf-builder:0.12.5-alpine3.10-606718795 \
    /bin/wkhtmltopdf /bin/wkhtmltopdf
ENV BUILD_LOG=https://api.travis-ci.org/v3/job/606718795/log.txt

RUN [ "$(sha256sum /bin/wkhtmltopdf | awk '{ print $1 }')" == \
      "$(wget -q -O - $BUILD_LOG | sed -n '13685p' | awk '{ print $1 }')" ]

#RUN node -v
RUN convert --version
RUN ruby -v
RUN mysql --version
RUN /bin/wkhtmltopdf --version
# RUN openssl -v

CMD [ "irb" ]
