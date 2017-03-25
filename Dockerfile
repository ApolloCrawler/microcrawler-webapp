# FROM bitwalker/alpine-erlang:19.2.1
FROM bitwalker/alpine-elixir-phoenix:latest

# Set the locale
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV MIX_ENV prod
ENV TERM xterm

RUN apk add --update \
  curl \
  python=2.7.12-r0 \
  git-perl \
  bash \
  make \
  gcc \
  g++ \
#  erlang \
#  erlang-mnesia \
#  erlang-public-key \
#  erlang-crypto \
#  erlang-ssl \
#  erlang-sasl \
#  erlang-asn1 \
#  erlang-inets \
#  erlang-os-mon \
#  erlang-xmerl \
#  erlang-eldap \
#  erlang-syntax-tools \
  && rm -rf /var/cache/apk/*

# Switch to directory with sources
WORKDIR /src

# Install Hex+Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copy required stuff
ADD . .

RUN mix deps.get \
  mix deps.compile

RUN npm install

RUN mix compile \
  && mix phoenix.digest \
  && mix ecto.create

ADD .docker/start.sh /start.sh

CMD ["/start.sh"]
