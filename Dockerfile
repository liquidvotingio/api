# Builder image
FROM bitwalker/alpine-elixir-phoenix:latest AS phx-builder

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

COPY --from=phx-builder /opt/app/_build/prod/rel/liquid_voting .

EXPOSE 4000
ENV PORT=4000 MIX_ENV=prod

ENTRYPOINT ["./bin/liquid_voting"]

# docker run -e SECRET_KEY_BASE=$(mix phx.gen.secret) -e liquid_voting:latest
CMD ["start"]
