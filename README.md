# Hermes Agent × Crazyrouter

> Use [Hermes Agent](https://github.com/nousresearch/hermes-agent) with [Crazyrouter](https://crazyrouter.com) — one API key for 600+ AI models, at prices 30-50% below going direct.

## Why Crazyrouter?

Hermes uses OpenRouter by default. Crazyrouter is a **drop-in replacement** with the same API format — just a different base URL and API key. Benefits:

| Feature | OpenRouter | Crazyrouter |
|---------|-----------|-------------|
| Models | 300+ | 600+ |
| Pricing | Standard | 30-50% cheaper |
| API format | OpenAI-compatible | OpenAI-compatible ✅ |
| Free tier | ✅ | ✅ |

## Quick Setup (One Command)

```bash
curl -fsSL https://raw.githubusercontent.com/xujfcn/crazyrouter-hermes/main/setup-crazyrouter.sh | bash
```

Or with your API key pre-set:

```bash
CRAZYROUTER_API_KEY=your-key-here curl -fsSL https://raw.githubusercontent.com/xujfcn/crazyrouter-hermes/main/setup-crazyrouter.sh | bash
```

Get your free API key at [crazyrouter.com](https://crazyrouter.com).

## Manual Setup

### 1. Install Hermes Agent

```bash
pip install hermes-agent
```

### 2. Configure provider

Edit `~/.hermes/config.yaml`:

```yaml
model:
  provider: "openrouter"          # reuse OpenRouter-compatible path
  base_url: "https://crazyrouter.com/v1"
  default: "anthropic/claude-opus-4.6"
```

### 3. Set API key

Edit `~/.hermes/.env`:

```bash
OPENROUTER_API_KEY=your-crazyrouter-api-key
```

> Hermes reads `OPENROUTER_API_KEY` when `provider: "openrouter"` is set.
> Crazyrouter's API is fully compatible — no code changes needed.

### 4. Start Hermes

```bash
hermes
```

## Switching Models

Crazyrouter gives you access to all major model families:

```bash
hermes model
```

Popular choices:

| Model | Use case | Approx. cost |
|-------|----------|-------------|
| `anthropic/claude-opus-4.6` | Best reasoning, coding | ~$15/M tokens |
| `anthropic/claude-sonnet-4-5` | Balanced speed/quality | ~$3/M tokens |
| `openai/gpt-5.2` | General purpose | ~$12/M tokens |
| `google/gemini-3-pro` | Multimodal, long context | ~$7/M tokens |
| `deepseek/deepseek-r2` | Budget reasoning | ~$0.5/M tokens |
| `google/gemini-3-flash` | Fast, cheap | ~$0.1/M tokens |

## Verify Setup

```bash
hermes chat "what model are you using and what is your base URL?"
```

## Troubleshooting

**Error: invalid API key**
→ Check your key at [crazyrouter.com/dashboard](https://crazyrouter.com/dashboard)

**Error: model not found**
→ Run `hermes model list` to see available models

**Want to switch back to OpenRouter?**

```yaml
# ~/.hermes/config.yaml
model:
  provider: "openrouter"
  base_url: "https://openrouter.ai/api/v1"  # restore default
```

## Links

- [Crazyrouter](https://crazyrouter.com) — AI API gateway
- [Hermes Agent](https://github.com/nousresearch/hermes-agent) — The agent
- [Crazyrouter Docs](https://crazyrouter.com/docs) — API reference
- [Crazyrouter Pricing](https://crazyrouter.com/pricing) — Model pricing
