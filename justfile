set shell := ["bash", "-euo", "pipefail", "-c"]

base_image := "dolfinx/dolfinx:nightly"
image := "fenicsx-template:dev"
container := "fenicsx-template"
hostname := "fenicsx-template"

# List recipes
[private]
default:
    @just --list

# Pull dolfinx/dolfinx:nightly
pull:
    docker pull {{ base_image }}

# Build the project image
build:
    docker build --pull --build-arg BASE_IMAGE={{ base_image }} --tag {{ image }} .

# Start the project container in the background
up:
    #!/usr/bin/env bash
    set -euo pipefail
    if ! docker image inspect {{ image }} >/dev/null 2>&1; then
        just build
    fi
    if docker container inspect {{ container }} >/dev/null 2>&1; then
        docker start {{ container }} >/dev/null
    else
        docker run --detach --name {{ container }} --hostname {{ hostname }} \
            --volume "{{ justfile_directory() }}:/app" \
            --workdir /app \
            {{ image }} \
            sleep infinity >/dev/null
    fi
    echo "Container {{ container }} is running. Enter it with 'just shell'."

# Stop and remove the project container
down:
    #!/usr/bin/env bash
    set -euo pipefail
    docker rm --force {{ container }} >/dev/null 2>&1 || true
    echo "Container {{ container }} is stopped."

# Open the embedded-templates style zsh in the running container
shell: up
    docker exec --interactive --tty {{ container }} zsh

# Run a command in the image with the repository mounted
run *args:
    docker run --rm \
        --volume "{{ justfile_directory() }}:/app" \
        --workdir /app \
        {{ image }} \
        {{ args }}

# Solve the Poisson problem. Optional mesh size: `just demo 32`
demo n="16":
    docker run --rm \
        --volume "{{ justfile_directory() }}:/app" \
        --workdir /app \
        {{ image }} \
        python -m fenicsx_template {{ n }}

# Solve with several MPI ranks: `just demo-mpi 4`
demo-mpi ranks="2" n="16":
    docker run --rm \
        --volume "{{ justfile_directory() }}:/app" \
        --workdir /app \
        {{ image }} \
        mpirun -n {{ ranks }} python -m fenicsx_template {{ n }}

# Solve with the complex DOLFINx build
demo-complex n="16":
    docker run --rm \
        --volume "{{ justfile_directory() }}:/app" \
        --workdir /app \
        {{ image }} \
        bash -lc "source /usr/local/bin/dolfinx-complex-mode && python -m fenicsx_template {{ n }}"

# Run pytest. Extra arguments are forwarded: `just test -k poisson`
test *args:
    docker run --rm \
        --volume "{{ justfile_directory() }}:/app" \
        --workdir /app \
        {{ image }} \
        python -m pytest {{ args }}

# Lint and format-check with ruff
lint:
    docker run --rm \
        --volume "{{ justfile_directory() }}:/app" \
        --workdir /app \
        {{ image }} \
        bash -lc "ruff check . && ruff format --check ."

# Update uv.lock with the uv version installed in the image
lock:
    docker run --rm \
        --volume "{{ justfile_directory() }}:/app" \
        --workdir /app \
        {{ image }} \
        uv lock

# Lint and test
ci: lint test
