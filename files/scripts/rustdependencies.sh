#!/usr/bin/env bash
set -euo pipefail

function install_eww() {
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
