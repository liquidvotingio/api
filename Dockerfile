FROM bitwalker/alpine-elixir-phoenix:latest AS phx-builder

# Set exposed ports
ENV MIX_ENV=prod

# Cache elixir deps
ADD mix.exs mix.lock ./
RUN mix deps.get
RUN mix deps.compile

# Copy everything over from repo that's not ignored in .dockerignore
COPY . .

# Build release
RUN mix release

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
