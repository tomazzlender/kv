FROM hexpm/elixir:1.14.3-erlang-25.3-debian-bullseye-20230227-slim AS build-env

ADD . /app
WORKDIR /app
ENV MIX_ENV=prod

RUN mix local.hex --force
RUN mix local.rebar --force

RUN mix clean
RUN mix deps.get
RUN mix deps.compile
RUN mix release
