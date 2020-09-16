FROM circleci/ruby:2.7.1-node-browsers

USER root

RUN apt-get update \
  && mkdir -p /usr/share/man/man1 \
  && apt-get install -y \
    git mercurial xvfb \
    locales libssl-dev sudo openssh-client ca-certificates tar gzip parallel \
    net-tools netcat unzip zip bzip2 gnupg curl wget libsodium-dev default-mysql-client libsqlite3-dev \
    wkhtmltopdf

ENV WKHTMLTOPDF_BINARY /usr/bin/wkhtmltopdf

USER circleci
