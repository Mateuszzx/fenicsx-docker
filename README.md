# FEniCSx template

Project template for [DOLFINx](https://github.com/FEniCS/dolfinx) using [uv](https://docs.astral.sh/uv/), a [justfile](https://just.systems/), and the official image `dolfinx/dolfinx:nightly`.

DOLFINx, Basix, UFL, FFCx, PETSc, and mpi4py come from that image. uv installs this project, and any extra Python packages you add, into the image virtual environment at `/dolfinx-env`.

## Prerequisites

- Docker
- [just](https://just.systems/man/en/)

uv 0.13.6 is copied into the image. Install uv on the host only if you want to edit the lockfile without Docker.

## Quick start

```bash
just build
just demo
just test
```

`just up` starts the container. `just shell` opens zsh in it, and `just down` stops it. `just demo 32` uses a finer mesh. `just demo-mpi 4` runs four MPI ranks.

## Commands

| Command | What it does |
| --- | --- |
| `just pull` | Pull `dolfinx/dolfinx:nightly` |
| `just build` | Build `fenicsx-template:dev` |
| `just up` | Start the container in the background |
| `just down` | Stop and remove that container |
| `just shell` | Open zsh in the running container |
| `just demo [n]` | Solve the manufactured Poisson problem |
| `just demo-mpi [ranks] [n]` | Same solve under `mpirun` |
| `just demo-complex [n]` | Same solve with the complex DOLFINx build |
| `just test [pytest args]` | Run pytest |
| `just lint` | Run ruff |
| `just lock` | Refresh `uv.lock` inside the image |
| `just run <cmd>` | Run a command with the repository mounted |
| `just ci` | Lint and test |

The project is copied into `/dolfinx-env` when the image is built. Rebuild after changing Python code, then run `just down` and `just up` so the container uses the new image. `just up` mounts the repository at `/app`. After changing `pyproject.toml`, run `just lock` and then `just build`.

`just shell` opens zsh in that container. The prompt, fzf keybindings, autosuggestions, syntax highlighting, and Ctrl-R history search match the embedded-templates shell. The prompt shows the container hostname `fenicsx-template`. `~/.zshrc` also sources `~/.local/bin/env`, which puts `~/.local/bin` on `PATH`.

## Dependencies

Add a package to `pyproject.toml`, then lock and rebuild:

```toml
dependencies = [
    "scipy>=1.14",
]
```

```bash
just lock
just build
```

Leave `fenics-dolfinx`, `fenics-basix`, `fenics-ufl`, and `fenics-ffcx` out of that list. The nightly image already provides them, built against its PETSc. uv sync uses `--inexact` so those preinstalled packages stay in `/dolfinx-env`.

The nightly image currently provides Python 3.14 (`.python-version`). Update that file if a later nightly moves Python. Real mode is the default. `source /usr/local/bin/dolfinx-complex-mode` switches to the complex build; `just demo-complex` does that for you.

## GitHub Actions

[`.github/workflows/docker.yml`](.github/workflows/docker.yml) builds the Dockerfile.

- Pull requests build `linux/amd64` and run ruff and pytest. They do not push.
- Pushes to `main` or `master`, tags `v*.*.*`, manual runs, and a weekly schedule publish to `ghcr.io/<owner>/<repo>`.
- Published tags: `latest` on the default branch, the branch or git tag name, a short commit sha, semver (`1.2.3`, `1.2`) for version tags, and `YYYYMMDD` for the weekly rebuild.
- The published image is `linux/amd64` and `linux/arm64`, matching the DOLFINx nightly image.

The workflow grants `packages: write` for the publish job. If the repository only allows read-only tokens, enable read and write permissions under Settings → Actions → General. New GHCR packages are private until you change the package visibility.

The default branch names in the workflow are `main` and `master`. Change those if the repository uses another name.

## Layout

```text
Dockerfile              image based on dolfinx/dolfinx:nightly
docker/zshrc            embedded-templates style zsh configuration
docker/zprofile         login shell hook that sources ~/.zshrc
docker/env              PATH helper sourced by ~/.zshrc
justfile                build, run, test, and lock commands
pyproject.toml          project metadata and Python dependencies
uv.lock                 locked Python dependencies
src/fenicsx_template/   Poisson demo
tests/                  pytest checks for that demo
.github/workflows/      build, test, and publish the image
```

The demo solves `-Δu = 2 π² sin(π x) sin(π y)` on the unit square, with exact solution `u = sin(π x) sin(π y)`. `just demo` prints the L2 error.
