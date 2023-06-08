FROM elixir:1.14.5 AS build-env

ADD . /app
WORKDIR /app
ENV MIX_ENV=prod

RUN mix local.hex --force
RUN mix local.rebar --force

RUN mix clean
RUN mix deps.get
RUN mix deps.compile
RUN mix release
