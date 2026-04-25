# AI Gateway — Workflow Patterns

> Detail file for the ai-gateway skill. Read only when designing multi-step agent workflows.

## How Workflows Work

The `/v1/workflow` endpoint executes a DAG (directed acyclic graph) of steps:

1. Steps with no `dependsOn` start **immediately and in parallel**
2. Steps with `dependsOn` wait for all listed dependencies to complete
3. `{{stepId}}` in a prompt is replaced with that step's output text
4. Total timeout = per-step timeout × number of steps

## Pattern: Fan-out / Fan-in

Multiple independent research steps, then a synthesis step.

```
research_a ──┐
research_b ──┼──→ synthesis
research_c ──┘
```

```python
resp = requests.post(f"{GATEWAY_URL}/v1/workflow", json={
    "timeout": 600,
    "steps": [
        {"id": "market",     "prompt": "Research market size for X"},
        {"id": "competitors","prompt": "List top 5 competitors of X"},
        {"id": "trends",     "prompt": "What are current trends in X industry"},
        {"id": "report",     "prompt": "Write an investment memo using:\n\nMarket: {{market}}\n\nCompetitors: {{competitors}}\n\nTrends: {{trends}}",
                              "dependsOn": ["market", "competitors", "trends"]}
    ]
})
```

`market`, `competitors`, and `trends` run in parallel. `report` starts only after all three finish.

## Pattern: Sequential Pipeline

Each step builds on the previous — use for tasks where order matters.

```
extract → analyze → format
```

```python
steps = [
    {"id": "extract", "prompt": "Extract all financial data from this text: ..."},
    {"id": "analyze", "prompt": "Analyze these financials for red flags: {{extract}}",
                       "dependsOn": ["extract"]},
    {"id": "format",  "prompt": "Format the analysis as a markdown table: {{analyze}}",
                       "dependsOn": ["analyze"]}
]
```

## Pattern: Verify and Correct

First attempt, then a verification/correction pass.

```python
steps = [
    {"id": "draft",  "prompt": "Write a Python function that parses CSV and returns JSON"},
    {"id": "review", "prompt": "Review this code for bugs, edge cases, and security issues:\n\n{{draft}}",
                      "dependsOn": ["draft"]},
    {"id": "final",  "prompt": "Fix all issues found in the review and return the corrected code:\n\nOriginal: {{draft}}\n\nReview: {{review}}",
                      "dependsOn": ["draft", "review"]}
]
```

## Pattern: Research with Web Search

The gateway has web search — use it for fact-checking or current data.

```python
steps = [
    {"id": "search", "prompt": "Search the web and find the current pricing plans for AWS Lambda, Google Cloud Functions, and Azure Functions. Include free tier limits."},
    {"id": "compare","prompt": "Create a comparison table from: {{search}}",
                      "dependsOn": ["search"]}
]
```

## Pattern: Diamond Dependency

```
          ┌──→ pros ──┐
evaluate ─┤           ├──→ decision
          └──→ cons ──┘
```

```python
steps = [
    {"id": "evaluate", "prompt": "Summarize the proposal: ..."},
    {"id": "pros",     "prompt": "List all benefits of: {{evaluate}}",
                        "dependsOn": ["evaluate"]},
    {"id": "cons",     "prompt": "List all risks and downsides of: {{evaluate}}",
                        "dependsOn": ["evaluate"]},
    {"id": "decision", "prompt": "Make a recommendation based on:\n\nPros: {{pros}}\n\nCons: {{cons}}",
                        "dependsOn": ["pros", "cons"]}
]
```

## Tips

- **Keep prompts focused** — each step should do one thing well
- **Use `maxTurns`** — for simple steps (summarization, formatting), set `"maxTurns": 3` to save cost
- **Check cost** — the response includes `total_cost_usd` and per-step `cost_usd`
- **Timeout per step** — `timeout` is per-step, not total
- **Error propagation** — if a step fails, all dependent steps fail too
