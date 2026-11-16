#!/usr/bin/env bash
# Puts PS5MG-Enhanced on the console over FTP (2121): the title, the 512-path models, a test image. Nothing is deleted.
set -u
H=${PS5_HOST:?set PS5_HOST to the console address}
cd "$(dirname "$0")/.." || exit 1
put() { # local remote
  start=$(date +%s)
  curl -sS --ftp-create-dirs -T "$1" "ftp://$H:2121$2" && echo "ok  $2 ($(stat -c %s "$1") bytes, $(( $(date +%s) - start )) s)" || echo "FAIL $2"
}
for f in build/title/PPSA99578/eboot.bin build/title/PPSA99578/sce_module/libc.prx build/title/PPSA99578/sce_sys/*; do
  put "$f" "/data/homebrew/PPSA99578/${f#build/title/PPSA99578/}"
done
put samples/sword.png /data/PS5MG-Enhanced/sword.png
for f in models/q4/*.gguf; do
  case $f in *_1024.gguf) continue ;; esac
  put "$f" "/data/PS5MG-Enhanced/models/q4/$(basename "$f")"
done
echo "/data/PS5MG-Enhanced/sword.png /data/PS5MG-Enhanced/sword.glb -m /data/PS5MG-Enhanced/models/q4 --res 512 -s 1234 --fa-fast --steps 8 --box-uv --no-texture -v" > /tmp/mg-args.txt
put /tmp/mg-args.txt /data/PS5MG-Enhanced/args.txt
echo UPLOAD-DONE
