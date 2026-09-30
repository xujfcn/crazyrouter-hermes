# Crazyrouter × Hermes Agent Setup

<!-- crazyrouter-links -->
> - 📖 **完整接入指南（手动配置、Base URL 规则、推荐模型、FAQ）**：https://crazyrouter.com/zh/integrations/hermes?utm_source=github&utm_medium=readme&utm_campaign=hermes
> - 💰 **模型价格对比（官方 / Azure / Bedrock / Vertex / Crazyrouter，每日核对）**：https://crazyrouter.com/zh/pricing?utm_source=github&utm_medium=readme&utm_campaign=hermes
> - 🗂 **按厂商浏览全部模型**：https://crazyrouter.com/zh/models?utm_source=github&utm_medium=readme&utm_campaign=hermes

One-click setup to connect [Hermes Agent](https://github.com/NousResearch/hermes-agent) with [Crazyrouter](https://crazyrouter.com) — access 627+ AI models through a single API key.

## What This Does

- Configures Hermes Agent to use Crazyrouter as the AI provider
- Sets `https://cn.crazyrouter.com/v1` as the default base URL
- Lets you pick a default model (Claude, GPT, DeepSeek, Gemini, etc.)
- Optionally tests the connection
- Includes `setup-full.sh` for fresh machines: checks system environment, installs missing dependencies, installs Hermes Agent, then writes Crazyrouter config

## 中文说明

这个仓库用于一键把 [Hermes Agent](https://github.com/NousResearch/hermes-agent) 配置为使用 Crazyrouter。默认接入地址已经改为国内入口：

```text
https://cn.crazyrouter.com/v1
```

脚本会写入 `~/.hermes/.env` 和 `~/.hermes/config.yaml`，并在覆盖旧配置前生成 `.bak` 备份。

详细中文教程见：[README_ZH.md](./README_ZH.md)

## Quick Start

### Linux / macOS / WSL2

If Hermes Agent is already installed, run the lightweight configurator:

```bash
curl -fsSL https://raw.githubusercontent.com/xujfcn/crazyrouter-hermes/main/setup.sh | bash
```

For a fresh server or clean system, run the full installer. It checks the OS/package manager, installs basic dependencies, installs Hermes Agent, configures Crazyrouter, and optionally tests the API connection:

```bash
curl -fsSL https://raw.githubusercontent.com/xujfcn/crazyrouter-hermes/main/setup-full.sh | bash
```

Non-interactive mode:

```bash
CRAZYROUTER_API_KEY=sk-your-key \
  bash <(curl -fsSL https://raw.githubusercontent.com/xujfcn/crazyrouter-hermes/main/setup-full.sh) \
  --yes --model claude-opus-4-8
```

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/xujfcn/crazyrouter-hermes/main/setup.ps1 | iex
```

### Windows (CMD)

Download and run `setup.bat`:

```cmd
curl -o setup.bat https://raw.githubusercontent.com/xujfcn/crazyrouter-hermes/main/setup.bat
setup.bat
```

## Prerequisites

- [Hermes Agent](https://github.com/NousResearch/hermes-agent) installed
- A Crazyrouter API key — get one at [crazyrouter.com](https://crazyrouter.com)

## Available Models

After setup, switch models anytime inside Hermes:

```
/model claude-opus-4-8
/model gpt-5.5
/model claude-opus-4-7
/model gpt-5.4
/model claude-sonnet-4-6
/model gemini-3.1-pro
/model deepseek-v4-flash
/model gpt-4o
```

627+ models available. Full list at [crazyrouter.com](https://crazyrouter.com).

## Manual Setup

If you prefer to configure manually:

**~/.hermes/.env**
```
CRAZYROUTER_API_KEY=sk-your-crazyrouter-key
```

For Claude, use native Anthropic Messages:

```yaml
model:
  provider: "custom"
  default: "claude-opus-4-8"
  base_url: "https://cn.crazyrouter.com"
  api_mode: "anthropic_messages"
```

For non-Claude models, use OpenAI-compatible chat completions:

```yaml
model:
  provider: "custom"
  default: "gpt-5.5"
  base_url: "https://cn.crazyrouter.com/v1"
  api_mode: "chat_completions"
```

Claude models must not use `codex_responses` or `/v1/responses`. Rerun the setup script when switching between Claude and non-Claude model families so Hermes updates both the base URL and API mode.
## What is Crazyrouter?

Crazyrouter is an AI API gateway that gives you access to 627+ models (OpenAI, Anthropic, Google, DeepSeek, Gemini, and more) through a single API key, using Anthropic Messages for Claude and OpenAI-compatible chat for other models. Pay-as-you-go, no subscriptions.

- 🌐 Website: [cn.crazyrouter.com](https://cn.crazyrouter.com)
- 📖 Docs: [docs.crazyrouter.com](https://docs.crazyrouter.com)
- 💬 Telegram: [t.me/crzrouter](https://t.me/crzrouter)

## License

MIT
