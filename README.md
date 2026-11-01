# FEniCSx workspace

This repository builds the shared image `ghcr.io/mateuszzx/fenicsx-workspace`. New projects do not start from here. They start from the [`template`](template) submodule, which is the [template-fenicsx](https://github.com/Mateuszzx/template-fenicsx) repository.

```text
fenicsx-docker            this repo: image definition and publish workflow
  image/                  DOLFINx nightly, uv, and the zsh shell
  template/               submodule used as the project template
```

## Build the image

```bash
just build
```

On `main`, [`.github/workflows/workspace-image.yml`](.github/workflows/workspace-image.yml) publishes `linux/amd64` and `linux/arm64` to `ghcr.io/mateuszzx/fenicsx-workspace`. It also rebuilds weekly so `:latest` tracks `dolfinx/dolfinx:nightly`. A repository created from the template does not contain this workflow or a Dockerfile.

The publish job needs `packages: write`. New GHCR packages are private until you change the package visibility.

## New project

Clone the template repository, or use it as a GitHub template:

```bash
git clone git@github.com:Mateuszzx/template-fenicsx.git my-project
cd my-project
just pull
just up
just shell
```

The template pulls the image built here and mounts the project into it.
