#!/usr/bin/env bash
# Re-vendors the package icons from Simple Icons (CC0) and recomputes the
# per-theme colours in packages.json. See README.md for why they are vendored
# and why the brand colours are adjusted.
#
# Usage: .github/pages/icons/fetch-icons.sh
set -Eeuo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKGS="${HERE}/../packages.json"
CDN="https://cdn.jsdelivr.net/npm/simple-icons@latest"

# package id -> Simple Icons slug. "-" means no upstream mark exists; those
# packages fall back to a monogram tile. Several packages share a mark on
# purpose: the GNU toolchain pieces, and the individual Kubernetes components.
read -r -d '' MAP <<'EOF' || true
gcc gnu
coreutils gnu
binutils gnu
strace -
nodejs nodedotjs
luajit lua
torch pytorch
transformers huggingface
onnxruntime onnx
kubernetes kubernetes
calico -
loki grafana
kube-apiserver kubernetes
kube-controller-manager kubernetes
kube-scheduler kubernetes
kube-proxy kubernetes
etcd etcd
cmake cmake
ninja -
sqlite sqlite
python python
ruby ruby
zstd -
protobuf -
grpc -
ffmpeg ffmpeg
dav1d -
x265 -
svt-av1 -
llama-cpp -
box64 -
nim nim
opentofu opentofu
docker docker
github-actions-riscv githubactions
EOF

echo "Fetching Simple Icons metadata..."
META="$(mktemp)"; trap 'rm -f "${META}"' EXIT
curl -fsSL --retry 3 --retry-delay 2 -o "${META}" "${CDN}/data/simple-icons.json"

# Download each distinct slug once.
echo "${MAP}" | awk '$2 != "-" {print $2}' | sort -u | while read -r slug; do
    if curl -fsSL --retry 3 --retry-delay 2 \
            -o "${HERE}/${slug}.svg" "${CDN}/icons/${slug}.svg"; then
        echo "  ok    ${slug}"
    else
        echo "  FAIL  ${slug} — no such icon upstream; map it to '-' instead" >&2
        exit 1
    fi
done

echo "Recomputing packages.json icon fields..."
MAP="${MAP}" META="${META}" PKGS="${PKGS}" python3 <<'PY'
import json, os, colorsys, hashlib

meta = {i['slug']: i['hex'] for i in json.load(open(os.environ['META']))}
mapping = dict(l.split() for l in os.environ['MAP'].splitlines() if l.strip())

def to_hsl(h):
    h = h.lstrip('#')
    r, g, b = (int(h[i:i+2], 16) / 255 for i in (0, 2, 4))
    hh, l, s = colorsys.rgb_to_hls(r, g, b)
    return hh, s, l

def to_hex(hh, s, l, lo, hi):
    r, g, b = colorsys.hls_to_rgb(hh, min(max(l, lo), hi), s)
    return '#%02X%02X%02X' % tuple(round(c * 255) for c in (r, g, b))

path = os.environ['PKGS']
data = json.load(open(path))
missing = []

for p in data['packages']:
    slug = mapping.get(p['id'], '-')
    if slug != '-' and slug in meta:
        hh, s, l = to_hsl(meta[slug])
        p['icon'] = slug + '.svg'
    else:
        # Stable hue per package id, so a rebuild never reshuffles the tiles.
        hh = int(hashlib.sha256(p['id'].encode()).hexdigest()[:8], 16) % 360 / 360
        s, l = 0.55, 0.5
        p.pop('icon', None)
        missing.append(p['id'])
    # Lightness bands chosen against the two page backgrounds: #fafafa and #0d1117.
    p['icon_color'] = to_hex(hh, s, l, 0.10, 0.42)
    p['icon_color_dark'] = to_hex(hh, s, l, 0.58, 0.82)

with open(path, 'w') as fh:
    json.dump(data, fh, indent=2, ensure_ascii=False)
    fh.write('\n')

print(f"  {len(data['packages']) - len(missing)} with a logo, "
      f"{len(missing)} on the monogram fallback: {', '.join(missing)}")
PY

echo "Done."
