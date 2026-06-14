# k8s-ci-helper

Container image with the Kubernetes manifest tooling used by CI, built once and reused by downstream jobs instead of downloading binaries during every pipeline run.

The image currently includes:

- `kustomize` 
- `kubeconform`
- `kube-linter` 
- `yamllint`

Images are published by GitHub Actions to:

```text
ghcr.io/hm-edu/k8s-ci-helper
```

Use `latest` for the current `main` branch image, a release tag such as `1.0.0`, or a `sha-...` tag when a downstream pipeline should pin an immutable build. Releases are managed automatically by Release Please from conventional commits.

Example GitLab CI usage:

```yaml
kustomize-build-check:
  image: ghcr.io/hm-edu/k8s-ci-helper:latest
  script:
    - |
      set -eu
      find . -name kustomization.yaml -not -path './.git/*' -exec dirname {} \; | sort | while IFS= read -r dir; do
        echo "kustomize build ${dir}"
        kustomize build "${dir}" > /dev/null
      done
```

Renovate updates the bundled applications through the `renovate:` comments next to the Dockerfile `ARG` pins. The normal Dockerfile and GitHub Actions managers also update the Alpine base image and workflow actions.