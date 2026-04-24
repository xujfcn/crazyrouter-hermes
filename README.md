# Crazyrouter × Hermes Agent Setup

One-click setup to connect [Hermes Agent](https://github.com/NousResearch/hermes-agent) with [Crazyrouter](https://crazyrouter.com) — access 627+ AI models through a single API key.

## What This Does

- Configures Hermes Agent to use Crazyrouter as the AI provider
- Sets `https://crazyrouter.com/v1` as the base URL
- Lets you pick a default model (Claude, GPT, DeepSeek, Gemini, Qwen, etc.)
- Optionally tests the connection

## Quick Start

### Linux / macOS / WSL2

```bash
curl -fsSL https://raw.githubusercontent.com/xujfcn/hermes-crazyrouter/main/setup.sh | bash
```

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/xujfcn/hermes-crazyrouter/main/setup.ps1 | iex
```

### Windows (CMD)

Download and run `setup.bat`:

```cmd
curl -o setup.bat https://raw.githubusercontent.com/xujfcn/hermes-crazyrouter/main/setup.bat
setup.bat
```

## Prerequisites

- [Hermes Agent](https://github.com/NousResearch/hermes-agent) installed
- A Crazyrouter API key — get one at [crazyrouter.com](https://crazyrouter.com)

## Available Models

After setup, switch models anytime inside Hermes:

```
/model claude-sonnet-4
/model gpt-4o
/model deepseek-chat
/model gemini-2.5-pro
/model qwen-max
/model claude-opus-4
/model gpt-5
```

627+ models available. Full list at [crazyrouter.com](https://crazyrouter.com).

## Manual Setup

If you prefer to configure manually:

**~/.hermes/.env**
```
OPENAI_API_KEY=sk-your-crazyrouter-key
OPENAI_BASE_URL=https://crazyrouter.com/v1
```

**~/.hermes/config.yaml**
```yaml
model:
  provider: "custom"
  default: "claude-sonnet-4"
  base_url: "https://crazyrouter.com/v1"
```

## What is Crazyrouter?

Crazyrouter is an AI API gateway that gives you access to 627+ models (OpenAI, Anthropic, Google, DeepSeek, Qwen, and more) through a single API key and a single OpenAI-compatible endpoint. Pay-as-you-go, no subscriptions.

- 🌐 Website: [crazyrouter.com](https://crazyrouter.com)
- 📖 Docs: [docs.crazyrouter.com](https://docs.crazyrouter.com)
- 💬 Telegram: [t.me/crzrouter](https://t.me/crzrouter)

## License

MIT
