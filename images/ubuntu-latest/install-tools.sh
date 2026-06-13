#!/usr/bin/env bash
set -euo pipefail

target_arch="${1:-amd64}"
go_version="${2:-1.26.4}"
node_major="${3:-24}"
java_version="${4:-25}"
dotnet_version="${5:-10.0}"
kubectl_version="${6:-1.33}"
helm_version="${7:-3.18.2}"
helm_apt_key_fingerprint="DDF78C3E6EBB2D2CC223C95C62BA89D07698DBC6"

case "${target_arch}" in
  amd64)
    deb_arch="amd64"
    go_arch="amd64"
    aws_arch="x86_64"
    ;;
  arm64)
    deb_arch="arm64"
    go_arch="arm64"
    aws_arch="aarch64"
    ;;
  *)
    echo "unsupported TARGETARCH: ${target_arch}" >&2
    exit 1
    ;;
esac

. /etc/os-release
ubuntu_version="${VERSION_ID}"
ubuntu_codename="${VERSION_CODENAME}"

apt-get update
apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  gpg \
  jq \
  lsb-release \
  software-properties-common \
  unzip

install -d -m 0755 /etc/apt/keyrings

curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  | gpg --dearmor -o /etc/apt/keyrings/githubcli-archive-keyring.gpg
chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
echo \
  "deb [arch=${deb_arch} signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  > /etc/apt/sources.list.d/github-cli.list

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod go+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=${deb_arch} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${ubuntu_codename} stable" \
  > /etc/apt/sources.list.d/docker.list

curl -fsSL https://packages.adoptium.net/artifactory/api/gpg/key/public \
  | gpg --dearmor -o /etc/apt/keyrings/adoptium.gpg
chmod go+r /etc/apt/keyrings/adoptium.gpg
echo \
  "deb [arch=${deb_arch} signed-by=/etc/apt/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb ${ubuntu_codename} main" \
  > /etc/apt/sources.list.d/adoptium.list

curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
  | gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg
chmod go+r /etc/apt/keyrings/microsoft.gpg
echo \
  "deb [arch=${deb_arch} signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/ubuntu/${ubuntu_version}/prod ${ubuntu_codename} main" \
  > /etc/apt/sources.list.d/microsoft.list

curl -fsSL "https://deb.nodesource.com/setup_${node_major}.x" -o /tmp/nodesource_setup.sh
bash /tmp/nodesource_setup.sh
rm -f /tmp/nodesource_setup.sh

curl -fsSL "https://pkgs.k8s.io/core:/stable:/v${kubectl_version}/deb/Release.key" \
  | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
chmod go+r /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo \
  "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${kubectl_version}/deb/ /" \
  > /etc/apt/sources.list.d/kubernetes.list

curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey -o /tmp/helm.gpg
if [ "$(gpg --show-keys --with-colons /tmp/helm.gpg | awk -F: '$1 == "fpr" {print $10}' | head -n 1)" != "${helm_apt_key_fingerprint}" ]; then
  echo "unexpected Helm APT key fingerprint" >&2
  exit 1
fi
gpg --dearmor -o /etc/apt/keyrings/helm.gpg /tmp/helm.gpg
chmod go+r /etc/apt/keyrings/helm.gpg
echo \
  "deb [signed-by=/etc/apt/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" \
  > /etc/apt/sources.list.d/helm-stable-debian.list
rm -f /tmp/helm.gpg

apt-get update
apt-get install -y --no-install-recommends \
  build-essential \
  docker-buildx-plugin \
  docker-ce-cli \
  docker-compose-plugin \
  "dotnet-sdk-${dotnet_version}" \
  gh \
  git \
  gettext-base \
  helm \
  iputils-ping \
  kubectl \
  make \
  nodejs \
  openssh-client \
  powershell \
  python-is-python3 \
  python3 \
  python3-dev \
  python3-pip \
  python3-venv \
  rsync \
  sudo \
  "temurin-${java_version}-jdk" \
  wget \
  xz-utils \
  zip

curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${aws_arch}.zip" -o /tmp/awscliv2.zip
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli
rm -rf /tmp/aws /tmp/awscliv2.zip

curl -fsSL "https://go.dev/dl/go${go_version}.linux-${go_arch}.tar.gz" -o /tmp/go.tgz
rm -rf /usr/local/go
tar -C /usr/local -xzf /tmp/go.tgz
rm -f /tmp/go.tgz

ln -sf /usr/local/go/bin/go /usr/local/bin/go
ln -sf /usr/local/go/bin/gofmt /usr/local/bin/gofmt

python3 -m pip install --no-cache-dir --break-system-packages pipx
python3 -m pipx ensurepath

mkdir -p /home/runner/.local/bin
chown -R runner:runner /home/runner/.local
