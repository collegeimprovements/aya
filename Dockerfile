# ── Build arguments ────────────────────────────────────────────────
#
# Override at build time:
#   docker build --build-arg ELIXIR_VERSION=1.19.1 ...
#
ARG ELIXIR_VERSION=1.20.0-rc.3
ARG OTP_VERSION=28.4.1
ARG DEBIAN_VERSION=trixie-20260316

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="${BUILDER_IMAGE}"

# ══════════════════════════════════════════════════════════════════
# Stage 1: Build
# ══════════════════════════════════════════════════════════════════

FROM ${BUILDER_IMAGE} AS builder

RUN apt-get update -y && \
    apt-get install -y build-essential git curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set the working directory so that ../../events/libs resolves to /src/events/libs
WORKDIR /src/yuan/aya

# Install hex + rebar
RUN mix local.hex --force && mix local.rebar --force

ENV MIX_ENV=prod

# ── Shared libs ───────────────────────────────────────────────────
# Copy vendored libs to the path mix.exs expects (../../events/libs)
COPY libs/ /src/events/libs/

# ── Dependencies ──────────────────────────────────────────────────
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV

# ── Config ────────────────────────────────────────────────────────
COPY config/config.exs config/prod.exs config/runtime.exs config/

# ── Compile deps ──────────────────────────────────────────────────
RUN mix deps.compile

# ── Assets ────────────────────────────────────────────────────────
COPY priv priv
COPY lib lib
COPY assets assets

RUN mix assets.deploy

# ── Compile app ───────────────────────────────────────────────────
RUN mix compile

# ── Release ───────────────────────────────────────────────────────
RUN mix release

# ══════════════════════════════════════════════════════════════════
# Stage 2: Runtime
# ══════════════════════════════════════════════════════════════════

FROM ${RUNNER_IMAGE}

# hexpm image has most deps; add tini for proper PID 1 and ensure locale
RUN apt-get update -y && \
    apt-get install -y tini && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

WORKDIR /app

RUN chown nobody:nogroup /app

ENV MIX_ENV=prod
ENV PHX_SERVER=true

COPY --from=builder --chown=nobody:nogroup /src/yuan/aya/_build/prod/rel/aya ./

USER nobody

EXPOSE 4000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:4000/api/health/ready || exit 1

ENTRYPOINT ["tini", "--"]
CMD ["/app/bin/aya", "start"]
