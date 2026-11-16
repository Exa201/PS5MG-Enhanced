# Building PS5MG-Enhanced

PS5MG-Enhanced is a PS5 title (`ps5/`): [trellis.cpp](https://github.com/pwilkin/trellis.cpp) with ggml-vulkan on
[PS5_Vulkan](https://github.com/mihawk-99/PS5_Vulkan)'s RADV build. The toolchain, the dependency setup and the
screen's UI kit come from the PS5SD submodule (`third_party/PS5SD`), the build recipe from PS5SD and PS5LM (GPL-3.0).
The toolchain runs on x86-64 Linux only, so build in GitHub Actions or in Docker.

## A. GitHub Actions (nothing to install)

Fork the repository and push, or run the `build` workflow by hand (`workflow_dispatch`). The first run takes a few hours
(RADV and ps5-opengl are built from source), later runs use the caches.

```sh
gh run list --workflow build --limit 5
gh run download <run-id> -n ps5mg-title -D build/title       # PPSA99578/
gh run download <run-id> -n ps5mg-tools -D build/tools       # launch-mg.elf
```

## B. Docker

```sh
git clone --recurse-submodules https://github.com/Exa201/PS5MG-Enhanced && cd PS5MG-Enhanced
git -C third_party/PS5SD submodule update --init third_party/ps5-homebrew-ui third_party/ftpsrv
docker build --platform linux/amd64 -t ps5sd-build third_party/PS5SD/docker
docker run --rm --platform linux/amd64 -v "$PWD":/work -w /work/third_party/PS5SD ps5sd-build scripts/setup-deps.sh
docker run --rm --platform linux/amd64 -v "$PWD":/work -w /work ps5sd-build scripts/build-mg.sh
docker run --rm --platform linux/amd64 -v "$PWD":/work -w /work ps5sd-build bash scripts/build-launcher.sh
```

The title folder ends up in `build/title/PPSA99578`. `MG_DISPLAY=0` builds without the screen.
`scripts/build-mg.sh` clones trellis.cpp and pwilkin's ggml at pinned commits into `.deps/` and applies the changes
listed in the README (patch scripts, `ps5/*.cpp`).

## Install on the console

1. Copy `PPSA99578/` to `/data/homebrew/PPSA99578` (FTP 2121 of a jailbroken console), rescan in ShadowMountPlus. The distinct title ID keeps the original PS5MG installed.
2. Weights to `/data/PS5MG-Enhanced/models/q4` (`tools/setup-weights.sh <console-ip>` downloads and uploads them after showing their licences).
3. Start the title: ShadowMountPlus' icon, or `tools/mg.sh launch` (elfldr 9021, `build/tools/launch-mg.elf`).
4. Open `http://<console>:7870`.

PS5MG-Enhanced stores jobs, models, configuration and output under `/data/PS5MG-Enhanced`; it does not share or remove the original `/data/PS5MG` data.
