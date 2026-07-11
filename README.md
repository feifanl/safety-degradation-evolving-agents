# Safety Degradation in Evolving Agents

Related work: [On Safety Risks in Experience-Driven Self-Evolving Agents (Zhao et al., 2026)](https://arxiv.org/pdf/2604.16968v1).

## Steps

1) Try and replicate the results
2) Use positive + negative contrastive pairs to extract a safety steering vectors, and use that vector to analyze and monitor safety degradation over time
3) Try and steer in opposite direction along trajectory of safety degradation, so as it degrades you increase the alpha
4) Look into how this might be replicated in actual memory management systems too
