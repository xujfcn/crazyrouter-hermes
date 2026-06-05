# Crazyrouter × Hermes Agent Setup

One-click setup to connect [Hermes Agent](https://github.com/NousResearch/hermes-agent) with [Crazyrouter](https://crazyrouter.com) — access 627+ AI models through a single API key.

## What This Does

- Configures Hermes Agent to use Crazyrouter as the AI provider
- Sets `https://cn.crazyrouter.com/v1` as the default base URL
- Lets you pick a default model (Claude, GPT, DeepSeek, Gemini, etc.)
- Optionally tests the connection

## 中文说明

这个仓库用于一键把 [Hermes Agent](https://github.com/NousResearch/hermes-agent) 配置为使用 Crazyrouter。默认接入地址已经改为国内入口：

```text
https://cn.crazyrouter.com/v1
```

脚本会写入 `~/.hermes/.env` 和 `~/.hermes/config.yaml`，并在覆盖旧配置前生成 `.bak` 备份。

详细中文教程见：[README_ZH.md](./README_ZH.md)

## Quick Start

### Linux / macOS / WSL2

```bash
curl -fsSL https://raw.githubusercontent.com/xujfcn/crazyrouter-hermes/main/setup.sh | bash
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
/model claude-sonnet-4.6
/model gemini-3.1-pro
/model deepseek-v4-flash
/model gpt-4o
```

627+ models available. Full list at [crazyrouter.com](https://crazyrouter.com).

## Manual Setup

If you prefer to configure manually:

**~/.hermes/.env**
```
OPENAI_API_KEY=sk-your-crazyrouter-key
OPENAI_BASE_URL=https://cn.crazyrouter.com/v1
```

**~/.hermes/config.yaml**
```yaml
model:
  provider: "custom"
  default: "claude-opus-4-8"
  base_url: "https://cn.crazyrouter.com/v1"
```

## What is Crazyrouter?

Crazyrouter is an AI API gateway that gives you access to 627+ models (OpenAI, Anthropic, Google, DeepSeek, Gemini, and more) through a single API key and a single OpenAI-compatible endpoint. Pay-as-you-go, no subscriptions.

- 🌐 Website: [cn.crazyrouter.com](https://cn.crazyrouter.com)
- 📖 Docs: [docs.crazyrouter.com](https://docs.crazyrouter.com)
- 💬 Telegram: [t.me/crzrouter](https://t.me/crzrouter)

## License

MIT
