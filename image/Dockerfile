# syntax=docker/dockerfile:1

# Reusable FEniCSx workspace. Project repositories pull this image.
# They do not rebuild DOLFINx, uv, or the shell.
ARG BASE_IMAGE=dolfinx/dolfinx:nightly
FROM ${BASE_IMAGE}

COPY --from=ghcr.io/astral-sh/uv:0.13.6 /uv /uvx /bin/

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        fzf \
        git \
        zsh \
        zsh-autosuggestions \
        zsh-syntax-highlighting \
    && rm -rf /var/lib/apt/lists/* \
    && git clone --depth 1 https://github.com/joshskidmore/zsh-fzf-history-search.git \
        /usr/local/share/zsh-plugins/zsh-fzf-history-search

# Project dependencies install into the image environment so Basix, UFL,
# FFCx, and PETSc stay in place. DOLFINx itself stays on PYTHONPATH.
ENV UV_PROJECT_ENVIRONMENT=/dolfinx-env \
    UV_PYTHON=/dolfinx-env/bin/python \
    UV_PYTHON_DOWNLOADS=never \
    UV_LINK_MODE=copy \
    UV_COMPILE_BYTECODE=1 \
    SHELL=/usr/bin/zsh

COPY env /root/.local/bin/env
COPY zshrc /root/.zshrc
COPY zprofile /root/.zprofile
COPY entrypoint.sh /usr/local/bin/fenicsx-entrypoint
RUN chmod +x /usr/local/bin/fenicsx-entrypoint

WORKDIR /app
ENTRYPOINT ["/usr/local/bin/fenicsx-entrypoint"]
CMD ["sleep", "infinity"]

LABEL org.opencontainers.image.title="fenicsx-workspace"
LABEL org.opencontainers.image.description="Reusable FEniCSx workspace on dolfinx/dolfinx:nightly"
LABEL org.opencontainers.image.base.name="dolfinx/dolfinx:nightly"
