# Replicating Results

Replicating [On Safety Risks in Experience-Driven Self-Evolving Agents (Zhao et al., 2026)](https://arxiv.org/pdf/2604.16968v1).

All differences from the paper are noted in *italics*.

## Chosen models

Everything should be runnable via vLLM, and fit within 192 GB of vRAM.

| Model | Size | Role |
|---|---|---|
| Qwen3-8B | 8B dense | small backbone |
| Qwen3-14B | 14B dense | mid backbone |
| Mistral Small 3.x 24B | 24B dense | mid backbone, **non-Qwen family** |
| Qwen3-VL-32B-Instruct | 32B dense | large backbone + **ASR judge** |

*The paper uses GPT-4o (backbone + judge), Claude-4.5-Sonnet, the full Qwen3 family including Qwen3-235B-A22B, and DeepSeek-V3.2.* The 675B-class MoE models
(Qwen3-235B-A22B, DeepSeek-V3.2, Mistral Large 3) **do not fit in 192 GB** and
are dropped from the local run; reach them via hosted API only if needed.
*ASR judging uses Qwen3-VL-32B-Instruct instead of GPT-4o.*

## Frameworks & environments

Two self-evolving memory frameworks over standard agent benchmarks:

- **AWM - Agent Workflow Memory** (offline evolution) - Table 1 results
- **ReasoningBank** (online evolution) - Figures 2–5 results

| Setting | Env / benchmark | Role |
|---|---|---|
| Web | WebArena | self-evolution interaction environment |
| Web | BrowserART | safety eval (ASR) |
| Web | Agent-SafetyBench (web subset) | safety eval (ASR) - *static text benchmark, no live browser* |
| Household embodied | SafeAgentBench (AI2-THOR) | self-evolution + safety eval |

Safety quantified via **ASR** (attack success rate). Retrieval: **top-3**
experiences/step. Decoding: **temp 0.1 (AWM), 0.7 (ReasoningBank)**.

## Repository layout

```
third_party/
  web/        # conda env: sde-web (py3.10) - Playwright/BrowserGym stack
    webarena/                 agent-workflow-memory/   reasoning-bank/
    browser-art/              agent-safetybench/
  embodied/   # conda env: sde-embodied (py3.10) - AI2-THOR/Unity stack
    safeagentbench/
envs/         # conda environment.yml: web / embodied / vllm
serving/      # vLLM launch script (serve.sh)
src/          # our glue code: memory/, eval/, patches/
configs/  scripts/  results/
```

`third_party/` is **gitignored**; each clone keeps its own `.git` (branch/commit
our edits there, mirror them as `src/patches/*.patch`). Reproduce with
`scripts/setup.sh`.

## Environments (three isolated conda envs)

The web and embodied stacks have **incompatible deps** (Chromium/Playwright vs.
Unity/OpenGL; the web stack breaks above py3.11), and vLLM wants its own
CUDA/torch env. So, we create three conda envs, all Python-pinned in `envs/*.yml`.

- `sde-web` (py3.10) - WebArena, AWM, ReasoningBank, BrowserART, Agent-SafetyBench
- `sde-embodied` (py3.10) - SafeAgentBench (`ai2thor==5.0.0`)
- `sde-vllm` (py3.12) - vLLM model serving

All benchmarks are **clients** of the vLLM endpoint (`OPENAI_BASE_URL=
http://localhost:8000/v1`, any non-empty `OPENAI_API_KEY`).
