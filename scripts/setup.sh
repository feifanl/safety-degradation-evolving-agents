#!/usr/bin/env bash
# Reproducible setup for replicating "On Safety Risks in Experience-Driven 
# Self-Evolving Agents."
#
# Clones each upstream benchmark/framework at the exact commit used in this
# replication into third_party/{web,embodied}. Re-running is safe: existing
# clones are left in place (only missing ones are cloned + checked out).
#
# It does NOT create conda envs or install deps — see envs/*.yml and the
# per-env install notes in REPLICATION.md for that (the stacks are mutually
# incompatible and must live in separate environments).
set -euo pipefail
cd "$(dirname "$0")/.."   # repo root

# name|relative_path|git_url|pinned_commit
REPOS=(
  "webarena|third_party/web/webarena|https://github.com/web-arena-x/webarena.git|dce04686a56253aefba7b18a4fa0937cf1dc987b"
  "agent-workflow-memory|third_party/web/agent-workflow-memory|https://github.com/zorazrw/agent-workflow-memory|8c0ff8cd11d648c8fceb99e4e42f37e3b75381b1"
  "reasoning-bank|third_party/web/reasoning-bank|https://github.com/google-research/reasoning-bank.git|ed80611788292ea739f1effd31f16c53823b8a0d"
  "browser-art|third_party/web/browser-art|https://github.com/scaleapi/browser-art.git|0d72180042f2a076c68e1114e7494cb3fc7dd30b"
  "agent-safetybench|third_party/web/agent-safetybench|https://github.com/thu-coai/Agent-SafetyBench.git|74feea8de601b3a1449a93fcf70017fe61556f73"
  "safeagentbench|third_party/embodied/safeagentbench|https://github.com/shengyin1224/SafeAgentBench.git|38ca3ab27eb8a5f5034a50bdcc5cbab23ce8f089"
)

for entry in "${REPOS[@]}"; do
  IFS='|' read -r name path url commit <<< "$entry"
  if [ -d "$path/.git" ]; then
    echo "[skip]  $name already present at $path"
    continue
  fi
  echo "[clone] $name -> $path"
  git clone --quiet "$url" "$path"
  git -C "$path" checkout --quiet "$commit"
done

echo
echo "All upstream repos present. Pinned commits:"
for entry in "${REPOS[@]}"; do
  IFS='|' read -r name path url commit <<< "$entry"
  printf "  %-22s %s\n" "$name" "$(git -C "$path" rev-parse --short HEAD 2>/dev/null || echo MISSING)"
done

echo
echo "Next: create the conda envs (see envs/*.yml) and re-apply local patches"
echo "with scripts/apply_patches.sh once you've saved edits into src/patches/."
