ARG BASE_IMAGE=ghcr.io/actions/actions-runner:latest
FROM ${BASE_IMAGE}

ARG TARGETARCH
ARG GO_VERSION=1.26.4
ARG NODE_MAJOR=24
ARG JAVA_VERSION=25
ARG DOTNET_VERSION=10.0
ARG KUBECTL_VERSION=1.33
ARG HELM_VERSION=3.18.2

ENV DEBIAN_FRONTEND=noninteractive
ENV ImageOS=ubuntu24
ENV ImageVersion=custom
ENV PATH=/home/runner/.local/bin:/usr/local/go/bin:${PATH}

USER root

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY install-tools.sh /tmp/install-tools.sh

RUN /tmp/install-tools.sh \
      "${TARGETARCH}" \
      "${GO_VERSION}" \
      "${NODE_MAJOR}" \
      "${JAVA_VERSION}" \
      "${DOTNET_VERSION}" \
      "${KUBECTL_VERSION}" \
      "${HELM_VERSION}" \
    && rm -f /tmp/install-tools.sh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER runner
