#!/bin/bash
# Sync the mounted project into the DOLFINx environment, then run the command.
set -euo pipefail

if [[ -f /app/pyproject.toml ]]; then
    uv sync --locked --inexact
fi

touch /tmp/fenicsx-ready
exec "$@"
