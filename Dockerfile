FROM bitwalker/alpine-elixir-phoenix:latest

# Set the locale
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV TERM xterm

RUN apk add --update \
  curl \
  python=2.7.12-r0 \
  git-perl \
  bash \
  make \
  gcc \
  g++ \
  && rm -rf /var/cache/apk/*

# Switch to directory with sources
WORKDIR /src

# Install Hex+Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copy required stuff
ADD . .

RUN mix deps.get \
    && npm install

ADD .docker/start.sh /start.sh

CMD ["/start.sh"]
