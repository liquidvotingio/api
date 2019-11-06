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
FROM bitwalker/alpine-elixir:latest

EXPOSE 4000
ENV PORT=4000 MIX_ENV=prod

COPY --from=phx-builder /opt/app /opt/app

WORKDIR /opt/app

RUN chown -R default: ./

USER default

ENTRYPOINT ["./_build/prod/rel/liquid_voting/bin/liquid_voting"]

# docker run -e SECRET_KEY_BASE=$(mix phx.gen.secret) -e liquid_voting:latest
CMD ["start"]
