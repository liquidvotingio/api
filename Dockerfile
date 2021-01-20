FROM bitwalker/alpine-elixir:1.11.0 AS release-builder

# Important!  Update this no-op ENV variable when this Dockerfile
# is updated with the current date. It will force refresh of all
# of the base images and things like `apt-get update` won't be using
# old cached versions when the Dockerfile is built.
ENV REFRESHED_AT=2021-01-20

# Install NPM
RUN \
    mkdir -p /opt/app && \
    chmod -R 777 /opt/app && \
    apk update && \
    apk --no-cache --update add \
      make \
      g++ \
      wget \
      curl \
      inotify-tools \
      nodejs \
      nodejs-npm && \
    npm install npm -g --no-progress && \
    update-ca-certificates --fresh && \
    rm -rf /var/cache/apk/*

# Add local node module binaries to PATH
ENV PATH=./node_modules/.bin:$PATH

# Ensure latest versions of Hex/Rebar are installed on build
ONBUILD RUN mix do local.hex --force, local.rebar --force

ENV MIX_ENV=prod

WORKDIR /opt/app

# Cache elixir deps
COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get
RUN mix deps.compile

# Compile project
COPY priv priv
COPY lib lib
RUN mix compile

# Build release
COPY rel rel
RUN mix release

# Release image
FROM alpine:3.9

RUN apk add --no-cache bash libstdc++ openssl

WORKDIR /opt/app

COPY --from=release-builder /opt/app/_build/prod/rel/liquid_voting .

EXPOSE 4000
ENV PORT=4000 MIX_ENV=prod

ENTRYPOINT ["./bin/liquid_voting"]

# docker run -e SECRET_KEY_BASE=$(mix phx.gen.secret) -e liquid_voting:latest
CMD ["start"]
