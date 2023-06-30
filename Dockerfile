# heavily borrowed from https://elixirforum.com/t/cannot-find-libtinfo-so-6-when-launching-elixir-app/24101/11?u=sigu
FROM elixir:1.14-otp-25 AS app_builder

ARG env=prod
ARG cyclonedx_cli_version=v0.24.0

ENV LANG=C.UTF-8 \
   TERM=xterm \
   MIX_ENV=$env

RUN mkdir /opt/release
WORKDIR /opt/release

RUN mix local.hex --force && mix local.rebar --force

RUN curl -L  https://github.com/CycloneDX/cyclonedx-cli/releases/download/$cyclonedx_cli_version/cyclonedx-linux-x64 --output cyclonedx-cli && chmod a+x cyclonedx-cli
RUN curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin

COPY mix.exs .
COPY mix.lock .
RUN mix deps.get && mix deps.compile

# Let's make sure we have node
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs

COPY assets ./assets
COPY config ./config
COPY lib ./lib
COPY priv ./priv
COPY Makefile ./Makefile

RUN mix sbom.install
RUN mix sbom.cyclonedx
RUN mix sbom.convert

# make sbom for the production docker image
RUN syft debian:bullseye-slim -o spdx > debian.buster_slim-spdx-bom.spdx
RUN syft debian:bullseye-slim -o spdx-json > debian.buster_slim-spdx-bom.json
RUN syft debian:bullseye-slim -o cyclonedx-json > debian.buster_slim-cyclonedx-bom.json
RUN syft debian:bullseye-slim -o cyclonedx > debian.buster_slim-cyclonedx-bom.xml

RUN cp *bom* ./priv/static/.well-known/sbom/
RUN mix assets.deploy
RUN mix release


FROM debian:bullseye-slim AS app

ARG CLIENT_ID=:sfractal2020
ARG MQTT_HOST="test.mosquitto.org"
ARG MQTT_PORT=1883
ARG USER_NAME=plug
ARG PASSWORD=fest


ENV LANG=C.UTF-8
ENV CLIENT_ID=$CLIENT_ID
ENV MQTT_HOST=$MQTT_HOST
ENV MQTT_PORT=$MQTT_PORT
ENV USER_NAME=$USER_NAME
ENV PASSWORD=$PASSWORD

RUN apt-get update && apt-get install -y openssl

RUN useradd --create-home app
WORKDIR /home/app
COPY --from=app_builder /opt/release/_build .
RUN chown -R app: ./prod
USER app

CMD ["./prod/rel/twinkly_maha/bin/twinkly_maha", "start"]
