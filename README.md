# GitHub Runner Images

Custom GitHub Actions runner images for Actions Runner Controller (ARC).

This repo currently builds and publishes one practical `ubuntu-latest`-style
runner image for ARC. It is not a byte-for-byte clone of GitHub-hosted runners,
but it covers the common toolchain most self-hosted workflows need:

- Official `actions-runner` base image
- Ubuntu userland and common build tooling
- `git`, `gh`, `curl`, `jq`, `zip`, `unzip`, `make`, `build-essential`
- `python3`, `pip`, `venv`
- `node` latest LTS
- `go`
- `temurin` latest LTS JDK
- `.NET` latest LTS SDK
- `powershell`
- `docker` CLI, `buildx`, `compose`
- `kubectl` and `helm`

## Image

- Image definition: `images/ubuntu-latest`
- Published image: `ghcr.io/aliktb/github-runner-images-ubuntu-latest`

The image is currently pinned to Ubuntu 24.04-era packages and common current
tooling versions. The folder name stays `ubuntu-latest` because that is how it
will usually be referenced by consumers.

Version policy:

- Use the official `actions-runner` base image
- Prefer the latest LTS major where a tool has an LTS track
- Prefer current stable releases for tools without an LTS model
- Avoid trying to exactly mirror every package on GitHub-hosted runners

Current defaults in the image:

- Node.js 24 LTS
- Temurin 25 LTS
- .NET 10 LTS
- Go 1.26.4

## Local Build

```bash
docker build -t github-runner-images:test images/ubuntu-latest
```

The image has been verified to build locally with `docker build`.

## Publishing

This repo includes a workflow that builds and publishes the image to GHCR on:

- pushes to `main`
- version tags like `v1.2.3`
- manual `workflow_dispatch`

The published image name is:

`ghcr.io/aliktb/github-runner-images-ubuntu-latest`

The package is published with OCI source metadata so GHCR associates it with
this repository.

The workflow:

- builds on pull requests without pushing
- pushes `latest`, branch, tag, and SHA tags on `main` and version tags
- uses the repository `GITHUB_TOKEN` to publish to GHCR

For workflows that use Docker-based actions or `container:` jobs, you still need
ARC container mode configured appropriately, usually `dind` or Kubernetes mode.
This image includes the Docker CLI, but it does not embed a daemon.
