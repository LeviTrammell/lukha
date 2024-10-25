#!/usr/bin/env bash
set -euo pipefail

function install_eww() {
  apt-get update && apt-get install -y \
    git \
    libgtk-3-dev \
    libgtk-layer-shell-dev \
    libpango1.0-dev \
    libgdk-pixbuf-2.0-0 \
    libdbusmenu-gtk3-dev \
    libcairo-dev \
    libglib2.0-dev \
    libgcc-12-dev

  git clone https://github.com/elkowar/eww /tmp/eww
  cargo build --release --no-default-features --features=wayland --manifest-path=/tmp/eww/Cargo.toml
  chmod +x "/tmp/eww/target/release/eww"
}

# function install_zellij() {
#   cargo install --locked zellij
# }
# 
function main() {
  install_eww
}

main
