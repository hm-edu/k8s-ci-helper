FROM alpine:3.24

ARG TARGETARCH=amd64

# renovate: datasource=github-releases depName=kubernetes-sigs/kustomize extractVersion=^kustomize/v(?<version>.*)$
ARG KUSTOMIZE_VERSION=5.8.3
# renovate: datasource=github-releases depName=yannh/kubeconform extractVersion=^v?(?<version>.*)$
ARG KUBECONFORM_VERSION=0.8.0
# renovate: datasource=github-releases depName=stackrox/kube-linter extractVersion=^v?(?<version>.*)$
ARG KUBE_LINTER_VERSION=0.8.3
# renovate: datasource=pypi depName=yamllint
ARG YAMLLINT_VERSION=1.38.0

RUN apk add --no-cache \
    ca-certificates \
    curl \
    gzip \
    py3-pip \
    python3 \
    tar

RUN set -eux; \
    case "${TARGETARCH}" in \
      amd64) kube_linter_arch_suffix="" ;; \
      arm64) kube_linter_arch_suffix="_arm64" ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fsSLo /tmp/kustomize.tar.gz "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_linux_${TARGETARCH}.tar.gz"; \
    tar -xzf /tmp/kustomize.tar.gz -C /usr/local/bin kustomize; \
    curl -fsSLo /tmp/kubeconform.tar.gz "https://github.com/yannh/kubeconform/releases/download/v${KUBECONFORM_VERSION}/kubeconform-linux-${TARGETARCH}.tar.gz"; \
    tar -xzf /tmp/kubeconform.tar.gz -C /usr/local/bin kubeconform; \
    curl -fsSLo /usr/local/bin/kube-linter "https://github.com/stackrox/kube-linter/releases/download/v${KUBE_LINTER_VERSION}/kube-linter-linux${kube_linter_arch_suffix}"; \
    chmod +x /usr/local/bin/kustomize /usr/local/bin/kubeconform /usr/local/bin/kube-linter; \
    pip3 install --no-cache-dir --break-system-packages "yamllint==${YAMLLINT_VERSION}"; \
    rm -rf /tmp/* /root/.cache

RUN set -eux; \
    kustomize version; \
    kubeconform -v; \
    kube-linter version; \
    yamllint --version

WORKDIR /work