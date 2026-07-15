#!/usr/bin/env bash
# Serve a local backbone with vLLM over an OpenAI-compatible endpoint.
# All benchmarks connect to it via OPENAI_BASE_URL=http://localhost:8000/v1
# (any non-empty OPENAI_API_KEY works — vLLM does not validate it by default).
#
#   conda activate sde-vllm
#   bash serving/serve.sh <model-key>
#
# Hardware note: this box is 4x RTX A6000 (48GB each, ~192GB total).
# Fully local backbones (all Apache-2.0 open weights):
#   qwen3-8b        Qwen/Qwen3-8B          dense    fits 1 GPU
#   qwen3-14b       Qwen/Qwen3-14B         dense    fits 1 GPU
#   mistral-small   Mistral small 3.x 24B  dense    fits 1-2 GPUs   (non-Qwen family)
#   qwen3-vl-32b    Qwen/Qwen3-VL-32B-Instruct   ~64GB BF16, TP=2  (also ASR judge)
# NOT locally runnable here (675B-class MoE): Qwen3-235B-A22B, DeepSeek-V3.2,
# Mistral Large 3 -> use hosted APIs if needed.
set -euo pipefail

MODEL_KEY="${1:-qwen3-vl-32b}"
PORT="${PORT:-8000}"

case "$MODEL_KEY" in
  qwen3-8b)      MODEL="Qwen/Qwen3-8B";               TP=1 ;;
  qwen3-14b)     MODEL="Qwen/Qwen3-14B";              TP=1 ;;
  mistral-small) MODEL="mistralai/Mistral-Small-3.2-24B-Instruct-2506"; TP=2 ;;
  qwen3-vl-32b)  MODEL="Qwen/Qwen3-VL-32B-Instruct";  TP=2 ;;
  *) echo "Unknown model key: $MODEL_KEY" >&2; exit 1 ;;
esac

echo "Serving $MODEL (served-model-name=$MODEL_KEY) on :$PORT with TP=$TP"
exec vllm serve "$MODEL" \
  --served-model-name "$MODEL_KEY" \
  --host 0.0.0.0 --port "$PORT" \
  --tensor-parallel-size "$TP"
