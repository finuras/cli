FROM ubuntu:22.04

ARG NODE_VERSION=16

ENV DEBIAN_FRONTEND noninteractive
ENV TZ=UTC

WORKDIR /opt

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update \
    && apt-get install -y gnupg gosu curl ca-certificates zip unzip git supervisor sqlite3 libcap2-bin libpng-dev python2 \
    && mkdir -p ~/.gnupg \
    && chmod 600 ~/.gnupg \
    && echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf \
    && echo "keyserver hkp://keyserver.ubuntu.com:80" >> ~/.gnupg/dirmngr.conf \
    && gpg --recv-key 0x14aa40ec0831756756d7f66c4f4ea0aae5267a6c \
    && gpg --export 0x14aa40ec0831756756d7f66c4f4ea0aae5267a6c > /usr/share/keyrings/ppa_ondrej_php.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/ppa_ondrej_php.gpg] https://ppa.launchpadcontent.net/ondrej/php/ubuntu jammy main" > /etc/apt/sources.list.d/ppa_ondrej_php.list \
    && apt-get update \
    && apt-get install -y php8.1-cli php8.1-dev \
         php8.1-sqlite3 php8.1-gd \
         php8.1-curl \
         php8.1-mbstring \
         php8.1-xml php8.1-zip php8.1-bcmath \
         php8.1-intl php8.1-readline \
         php8.1-msgpack php8.1-igbinary \
    && php -r "readfile('https://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer \
    && curl -sLS https://deb.nodesource.com/setup_$NODE_VERSION.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Build caches
RUN mkdir /temp && cd /temp \
    && composer create-project --ignore-platform-reqs laravel/laravel example-app \
    && composer require --ignore-platform-reqs  --dev \
        laravel/breeze \
        spatie/laravel-ray \
    && rm -rf example-app


COPY ./Taskfile /usr/local/bin/Taskfile
RUN chmod +x /usr/local/bin/Taskfile

ENTRYPOINT ["Taskfile"]
