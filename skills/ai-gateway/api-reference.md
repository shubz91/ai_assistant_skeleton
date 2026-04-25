# AI Gateway — API Reference

> Detail file for the ai-gateway skill. Read only when implementing API integration code.

## Gateway URL

Replace `http://ai-gateway.internal:8000` with your actual gateway endpoint.

---

## POST /v1/chat/completions

OpenAI-compatible chat endpoint with full tool access.

### Request

```json
{
  "messages": [
    {"role": "system", "content": "You are a helpful assistant"},
    {"role": "user", "content": "Summarize this document: ..."}
  ],
  "stream": false,
  "timeout": 120,
  "maxTurns": 25
}
```

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `messages` | array | **required** | OpenAI-format messages (role + content) |
| `stream` | boolean | `false` | Enable SSE streaming |
| `timeout` | number | `900` | Timeout in seconds (max 3600) |
| `maxTurns` | integer | `25` | Max agentic tool-use turns |

### Response (non-streaming)

```json
{
  "id": "chatcmpl-abc123",
  "object": "chat.completion",
  "choices": [
    {
      "message": {"role": "assistant", "content": "Here is the summary..."},
      "finish_reason": "stop"
    }
  ],
  "usage": {"input_tokens": 152, "output_tokens": 85},
  "cost_usd": 0.0312,
  "num_turns": 1
}
```

### Python — requests

```python
import requests

GATEWAY_URL = "http://ai-gateway.internal:8000"  # update to your gateway

resp = requests.post(f"{GATEWAY_URL}/v1/chat/completions", json={
    "messages": [{"role": "user", "content": "Summarize this text: ..."}],
    "timeout": 120
})
resp.raise_for_status()
result = resp.json()["choices"][0]["message"]["content"]
cost = resp.json().get("cost_usd")
```

### Python — OpenAI SDK

```python
from openai import OpenAI

ai = OpenAI(base_url="http://ai-gateway.internal:8000/v1", api_key="unused")

# Non-streaming
resp = ai.chat.completions.create(
    model="claude",
    messages=[{"role": "user", "content": "Summarize: ..."}]
)
result = resp.choices[0].message.content

# Streaming
stream = ai.chat.completions.create(
    model="claude",
    messages=[{"role": "user", "content": "Explain: ..."}],
    stream=True
)
for chunk in stream:
    if chunk.choices[0].delta.content:
        print(chunk.choices[0].delta.content, end="")
```

### JavaScript/TypeScript — fetch

```typescript
const GATEWAY_URL = "http://ai-gateway.internal:8000";  // update to your gateway

const resp = await fetch(`${GATEWAY_URL}/v1/chat/completions`, {
  method: "POST",
  headers: {"Content-Type": "application/json"},
  body: JSON.stringify({
    messages: [{role: "user", content: "Analyze: ..."}],
    timeout: 300
  })
});
const data = await resp.json();
const result = data.choices[0].message.content;
```

---

## POST /v1/workflow

Multi-step agent pipeline. Steps form a DAG — independent steps run in parallel.

### Request

```json
{
  "timeout": 600,
  "steps": [
    {"id": "research", "prompt": "Find top 3 competitors of Stripe"},
    {"id": "pricing",  "prompt": "Find Stripe's current pricing"},
    {"id": "report",   "prompt": "Compare: {{research}} vs {{pricing}}",
                        "dependsOn": ["research", "pricing"]}
  ]
}
```

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `steps` | array | **required** | Pipeline steps |
| `steps[].id` | string | **required** | Unique step identifier |
| `steps[].prompt` | string | **required** | Prompt — use `{{stepId}}` for output injection |
| `steps[].dependsOn` | string[] | `[]` | Step IDs that must complete first |
| `steps[].maxTurns` | integer | `25` | Max turns for this step |
| `timeout` | number | `900` | Per-step timeout in seconds |

### Response

```json
{
  "id": "workflow-abc123",
  "object": "workflow.completion",
  "result": "Final step output text...",
  "steps": [
    {"id": "research", "result": "...", "cost_usd": 0.02, "num_turns": 3},
    {"id": "pricing",  "result": "...", "cost_usd": 0.01, "num_turns": 1},
    {"id": "report",   "result": "...", "cost_usd": 0.03, "num_turns": 2}
  ],
  "total_cost_usd": 0.06,
  "total_turns": 6
}
```

### Python

```python
import requests

GATEWAY_URL = "http://ai-gateway.internal:8000"

resp = requests.post(f"{GATEWAY_URL}/v1/workflow", json={
    "timeout": 600,
    "steps": [
        {"id": "extract", "prompt": "Extract key facts from: ..."},
        {"id": "verify",  "prompt": "Verify facts: {{extract}}", "dependsOn": ["extract"]},
        {"id": "report",  "prompt": "Write verified summary: {{verify}}", "dependsOn": ["verify"]}
    ]
})
resp.raise_for_status()

final_output = resp.json()["result"]
total_cost = resp.json()["total_cost_usd"]
```

---

## GET /health

```json
{"status": "ok", "active": 1, "queued": 0}
```

## Error Handling

All errors return JSON:

```json
{"error": "description of what went wrong"}
```

Common errors:
- **Timeout**: increase `timeout` or simplify the prompt
- **Concurrency limit**: all slots busy — retry after checking `/health`
- **Step validation**: workflow step missing `id`/`prompt` or referencing unknown dependency

## Available Tools Inside the Gateway

| Tool | What it can do |
|------|---------------|
| Read | Read any file in the container |
| Write | Create/overwrite files |
| Edit | Modify existing files |
| Bash | Run shell commands |
| Glob | Find files by pattern |
| Grep | Search file contents with regex |
| Agent | Launch subagents for parallel sub-tasks |
| WebSearch | Search the internet |
| WebFetch | Fetch and read web pages |
