set shell := ["bash", "-euo", "pipefail", "-c"]

image := "ghcr.io/mateuszzx/fenicsx-workspace:latest"

# List recipes
[private]
default:
    @just --list

# Build the shared workspace image from image/
build:
    docker build --pull --tag {{ image }} image
