# This stage is responsible for holding onto
# your config without copying it directly into
# the final image
FROM scratch AS stage-files
COPY ./files /files

# Copy modules
# The default modules are inside blue-build/modules
# Custom modules overwrite defaults
FROM scratch AS stage-modules
COPY --from=ghcr.io/blue-build/modules:latest /modules /modules
COPY ./modules /modules

# Bins to install
# These are basic tools that are added to all images.
# Generally used for the build process. We use a multi
# stage process so that adding the bins into the image
# can be added to the ostree commits.
FROM scratch AS stage-bins
COPY --from=gcr.io/projectsigstore/cosign /ko-app/cosign /bins/cosign
COPY --from=docker.io/mikefarah/yq /usr/bin/yq /bins/yq
COPY --from=ghcr.io/blue-build/cli:latest-installer /out/bluebuild /bins/bluebuild

# Keys for pre-verified images
# Used to copy the keys into the final image
# and perform an ostree commit.
#
# Currently only holds the current image's
# public key.
FROM scratch AS stage-keys
COPY cosign.pub /keys/lukha-hyprland-nvidia.pub


# Main image
FROM ghcr.io/ublue-os/base-nvidia:40 as lukha-hyprland-nvidia
ARG RECIPE=./recipes/recipe-hyprland-nvidia.yml
ARG IMAGE_REGISTRY=localhost
ARG CONFIG_DIRECTORY="/tmp/files"
ARG MODULE_DIRECTORY="/tmp/modules"
ARG IMAGE_NAME="lukha-hyprland-nvidia"
ARG BASE_IMAGE="ghcr.io/ublue-os/base-nvidia"

# Key RUN
RUN --mount=type=bind,from=stage-keys,src=/keys,dst=/tmp/keys \
  mkdir -p /usr/etc/pki/containers/ \
  && cp /tmp/keys/* /usr/etc/pki/containers/ \
  && ostree container commit

# Bin RUN
RUN --mount=type=bind,from=stage-bins,src=/bins,dst=/tmp/bins \
  mkdir -p /usr/bin/ \
  && cp /tmp/bins/* /usr/bin/ \
  && ostree container commit

# Module RUNs
RUN \
--mount=type=bind,from=stage-files,src=/files,dst=/tmp/files,rw \
--mount=type=bind,from=stage-modules,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,from=ghcr.io/blue-build/cli:4f235be4f7ec2aa1a462565f4ba797554ac62edb-build-scripts,src=/scripts/,dst=/tmp/scripts/ \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-lukha-hyprland-nvidia-40,sharing=locked \
  /tmp/scripts/run_module.sh 'rpm-ostree' '{"type":"rpm-ostree","install":["sddm","sddm-themes","qt5-qtgraphicaleffects","qt5-qtquickcontrols2","qt5-qtsvg","kwallet","pam-kwallet"]}' \
  && ostree container commit
RUN \
--mount=type=bind,from=stage-files,src=/files,dst=/tmp/files,rw \
--mount=type=bind,from=stage-modules,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,from=ghcr.io/blue-build/cli:4f235be4f7ec2aa1a462565f4ba797554ac62edb-build-scripts,src=/scripts/,dst=/tmp/scripts/ \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-lukha-hyprland-nvidia-40,sharing=locked \
  /tmp/scripts/run_module.sh 'rpm-ostree' '{"type":"rpm-ostree","install":["rofi-wayland","power-profiles-daemon","xorg-x11-server-Xwayland","polkit","xfce-polkit","xdg-user-dirs","dbus-tools","dbus-daemon","wl-clipboard","pavucontrol","playerctl","qt5-qtwayland","qt6-qtwayland","vulkan-validation-layers","vulkan-tools","google-noto-emoji-fonts","gnome-disk-utility","ddcutil","wireplumber","pipewire","pamixer","pulseaudio-utils","network-manager-applet","NetworkManager-openvpn","NetworkManager-openconnect","bluez","bluez-tools","blueman","thunar","thunar-archive-plugin","thunar-volman","xarchiver","imv","p7zip","unrar","gvfs-mtp","gvfs-gphoto2","gvfs-smb","gvfs-nfs","gvfs-fuse","gvfs-archive","android-tools","slurp","grim","wlr-randr","wlsunset","brightnessctl","swaylock","swayidle","kanshi","foot","zsh","dunst","adwaita-qt5","fontawesome-fonts-all","gnome-themes-extra","gnome-icon-theme","paper-icon-theme","breeze-icon-theme","papirus-icon-theme"]}' \
  && ostree container commit
RUN \
--mount=type=bind,from=stage-files,src=/files,dst=/tmp/files,rw \
--mount=type=bind,from=stage-modules,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,from=ghcr.io/blue-build/cli:4f235be4f7ec2aa1a462565f4ba797554ac62edb-build-scripts,src=/scripts/,dst=/tmp/scripts/ \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-lukha-hyprland-nvidia-40,sharing=locked \
  /tmp/scripts/run_module.sh 'rpm-ostree' '{"type":"rpm-ostree","install":["hyprland","waybar","xdg-desktop-portal-hyprland","brightnessctl"]}' \
  && ostree container commit
RUN \
--mount=type=bind,from=stage-files,src=/files,dst=/tmp/files,rw \
--mount=type=bind,from=stage-modules,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,from=ghcr.io/blue-build/cli:4f235be4f7ec2aa1a462565f4ba797554ac62edb-build-scripts,src=/scripts/,dst=/tmp/scripts/ \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-lukha-hyprland-nvidia-40,sharing=locked \
  /tmp/scripts/run_module.sh 'files' '{"type":"files","files":[{"source":"system/hyprland","destination":"/"}]}' \
  && ostree container commit
RUN \
--mount=type=bind,from=stage-files,src=/files,dst=/tmp/files,rw \
--mount=type=bind,from=stage-modules,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,from=ghcr.io/blue-build/cli:4f235be4f7ec2aa1a462565f4ba797554ac62edb-build-scripts,src=/scripts/,dst=/tmp/scripts/ \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-lukha-hyprland-nvidia-40,sharing=locked \
  /tmp/scripts/run_module.sh 'files' '{"type":"files","files":[{"source":"system/usr","destination":"/usr"}]}' \
  && ostree container commit
RUN \
--mount=type=bind,from=stage-files,src=/files,dst=/tmp/files,rw \
--mount=type=bind,from=stage-modules,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,from=ghcr.io/blue-build/cli:4f235be4f7ec2aa1a462565f4ba797554ac62edb-build-scripts,src=/scripts/,dst=/tmp/scripts/ \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-lukha-hyprland-nvidia-40,sharing=locked \
  /tmp/scripts/run_module.sh 'script' '{"type":"script","scripts":["settheming.sh"]}' \
  && ostree container commit
RUN \
--mount=type=bind,from=stage-files,src=/files,dst=/tmp/files,rw \
--mount=type=bind,from=stage-modules,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,from=ghcr.io/blue-build/cli:4f235be4f7ec2aa1a462565f4ba797554ac62edb-build-scripts,src=/scripts/,dst=/tmp/scripts/ \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-lukha-hyprland-nvidia-40,sharing=locked \
  /tmp/scripts/run_module.sh 'script' '{"type":"script","scripts":["removeunprofessionalwallpapers.sh","sethyprlandwaybarmodules.sh"]}' \
  && ostree container commit
RUN \
--mount=type=bind,from=stage-files,src=/files,dst=/tmp/files,rw \
--mount=type=bind,from=stage-modules,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,from=ghcr.io/blue-build/cli:4f235be4f7ec2aa1a462565f4ba797554ac62edb-build-scripts,src=/scripts/,dst=/tmp/scripts/ \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-lukha-hyprland-nvidia-40,sharing=locked \
  /tmp/scripts/run_module.sh 'script' '{"type":"script","scripts":["setsddmtheming.sh"]}' \
  && ostree container commit
RUN \
--mount=type=bind,from=stage-files,src=/files,dst=/tmp/files,rw \
--mount=type=bind,from=stage-modules,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,from=ghcr.io/blue-build/cli:4f235be4f7ec2aa1a462565f4ba797554ac62edb-build-scripts,src=/scripts/,dst=/tmp/scripts/ \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-lukha-hyprland-nvidia-40,sharing=locked \
  /tmp/scripts/run_module.sh 'wayblue-signing' '{"type":"wayblue-signing"}' \
  && ostree container commit
RUN \
--mount=type=bind,from=stage-files,src=/files,dst=/tmp/files,rw \
--mount=type=bind,from=stage-modules,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,from=ghcr.io/blue-build/cli:4f235be4f7ec2aa1a462565f4ba797554ac62edb-build-scripts,src=/scripts/,dst=/tmp/scripts/ \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-lukha-hyprland-nvidia-40,sharing=locked \
  /tmp/scripts/run_module.sh 'systemd' '{"type":"systemd","system":{"enabled":["sddm-boot.service"]}}' \
  && ostree container commit

RUN rm -fr /tmp/* /var/* && ostree container commit

# Labels are added last since they cause cache misses with buildah
LABEL org.blue-build.build-id="bd234271-611f-4a73-865a-4dcf1b0362c2"
LABEL org.opencontainers.image.title="lukha-hyprland-nvidia"
LABEL org.opencontainers.image.description="ublue images for wayland compositors"
LABEL io.artifacthub.package.readme-url=https://raw.githubusercontent.com/blue-build/cli/main/README.md