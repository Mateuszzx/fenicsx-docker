# syntax=docker/dockerfile:1

# Official end-user image: real and complex DOLFINx, PETSc, and a virtual
# environment at /dolfinx-env. Override with --build-arg BASE_IMAGE=...
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

# Install this project into the image environment. A fresh .venv would not
# see Basix, UFL, FFCx, or the PETSc stack. --inexact keeps those packages,
# which are not listed in uv.lock. --no-editable copies the project into
# /dolfinx-env instead of linking it back to the source tree.
ENV UV_PROJECT_ENVIRONMENT=/dolfinx-env \
    UV_PYTHON=/dolfinx-env/bin/python \
    UV_PYTHON_DOWNLOADS=never \
    UV_LINK_MODE=copy \
    UV_COMPILE_BYTECODE=1 \
    SHELL=/usr/bin/zsh

WORKDIR /app

COPY pyproject.toml uv.lock ./
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked --inexact --no-install-project

COPY README.md ./
COPY src ./src
COPY tests ./tests
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked --inexact --no-editable

# Interactive zsh matches the embedded-templates shell: project prompt, fzf,
# autosuggestions, syntax highlighting, and Ctrl-R history search.
COPY docker/env /root/.local/bin/env
COPY docker/zshrc /root/.zshrc
COPY docker/zprofile /root/.zprofile

LABEL org.opencontainers.image.description="FEniCSx project template on dolfinx/dolfinx:nightly"
LABEL org.opencontainers.image.base.name="dolfinx/dolfinx:nightly"

CMD ["python", "-m", "fenicsx_template"]
