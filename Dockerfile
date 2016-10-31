FROM ubuntu:14.04

#RUN echo '\n\
#deb http://archive.ubuntu.com/ubuntu/ xenial main restricted\n\
#deb-src http://archive.ubuntu.com/ubuntu/ xenial main restricted\n\
#deb http://archive.ubuntu.com/ubuntu/ xenial-updates main restricted\n\
#deb-src http://archive.ubuntu.com/ubuntu/ xenial-updates main restricted\n\
#deb http://archive.ubuntu.com/ubuntu/ xenial universe\n\
#deb-src http://archive.ubuntu.com/ubuntu/ xenial universe\n\
#>> /etc/apt/sources.list

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
  && apt-get install -y \
    autoconf \
    build-essential \
    file \
    cmake \
    curl \
    git \
    libssl-dev \
    libreadline-dev \
    libncurses5-dev \
    m4 \
    make \
    sudo \
    wget \
    zlib1g-dev \
  && apt-get dist-upgrade -y

# Install nvm
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.1/install.sh | bash

# Install rustup
RUN curl -sSf https://static.rust-lang.org/rustup.sh | /bin/bash -s -- --verbose --channel=nightly

# Switch to directory with sources
WORKDIR /src

# Copy required stuff
ADD . .

RUN wget http://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb -P /root
RUN dpkg -i /root/erlang-solutions_1.0_all.deb
RUN rm /root/erlang-solutions_1.0_all.deb

RUN apt-get update && apt-get install -y --no-install-recommends erlang elixir

# Install mix related "package managers"
RUN mix local.rebar --force \
  && mix local.hex --force

RUN make build-debug

RUN mix deps.get \
  mix deps.compile \
  mix compile

RUN export NVM_DIR="/root/.nvm" \
  && [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  \
  && nvm install 6.6.0 \
  && npm install

ADD .docker/start.sh /start.sh

ENTRYPOINT ["/bin/bash", "/start.sh"]
