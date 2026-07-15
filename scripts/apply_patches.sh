#!/usr/bin/env bash
# Re-apply local edits to the vendored upstream repos.
#
# The vendored repos under third_party/ are gitignored by the outer repo, so
# our edits to them (e.g. pointing clients at the local vLLM endpoint, adding
# platform=CloudRendering to SafeAgentBench's AI2-THOR Controller) are NOT
# tracked here. Save each edit as a patch under src/patches/<name>.patch, e.g.:
#
#   git -C third_party/embodied/safeagentbench diff > src/patches/safeagentbench.patch
#
# This script applies every src/patches/*.patch to its matching repo so a fresh
# `scripts/setup.sh` clone can be brought to our modified state.
set -euo pipefail
cd "$(dirname "$0")/.."

shopt -s nullglob
patches=(src/patches/*.patch)
if [ ${#patches[@]} -eq 0 ]; then
  echo "No patches in src/patches/ yet. Save edits with:"
  echo "  git -C third_party/<...>/<repo> diff > src/patches/<repo>.patch"
  exit 0
fi

# Map patch basename -> repo path.
declare -A REPO_PATH=(
  [webarena]=third_party/web/webarena
  [agent-workflow-memory]=third_party/web/agent-workflow-memory
  [reasoning-bank]=third_party/web/reasoning-bank
  [browser-art]=third_party/web/browser-art
  [agent-safetybench]=third_party/web/agent-safetybench
  [safeagentbench]=third_party/embodied/safeagentbench
)

for p in "${patches[@]}"; do
  name="$(basename "$p" .patch)"
  path="${REPO_PATH[$name]:-}"
  if [ -z "$path" ]; then echo "[warn] no repo mapped for $p, skipping"; continue; fi
  echo "[apply] $p -> $path"
  git -C "$path" apply "../../../$p"
done
