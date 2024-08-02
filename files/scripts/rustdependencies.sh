#!/usr/bin/env bash
set -euo pipefail

function install_rust() {
  rpm-ostree install "rustup"
}

function cleanup() {
  rpm-ostree uninstall "rustup"
}

function install_eww() {
  git clone https://github.com/elkowar/eww /tmp/eww
  cargo build --release --no-default-features --features=wayland --manifest-path=/tmp/eww/Cargo.toml
  chmod +x "/tmp/eww/target/release/eww"
  install -m 755 "/tmp/eww/target/release/eww" 
  rm -rf /tmp/eww
}

function install_zellij() {
  cargo install --locked zellij
}

function main() {
  install_rust
  install_eww
  install_zellij
  cleanup
}

main
