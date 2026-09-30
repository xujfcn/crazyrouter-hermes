# Crazyrouter × Hermes Agent 一键配置说明

<!-- crazyrouter-links -->
> - 📖 **完整接入指南（手动配置、Base URL 规则、推荐模型、FAQ）**：https://crazyrouter.com/zh/integrations/hermes?utm_source=github&utm_medium=readme&utm_campaign=hermes
> - 💰 **模型价格对比（官方 / Azure / Bedrock / Vertex / Crazyrouter，每日核对）**：https://crazyrouter.com/zh/pricing?utm_source=github&utm_medium=readme&utm_campaign=hermes
> - 🗂 **按厂商浏览全部模型**：https://crazyrouter.com/zh/models?utm_source=github&utm_medium=readme&utm_campaign=hermes

这个仓库用于把 [Hermes Agent](https://github.com/NousResearch/hermes-agent) 一键配置为使用 Crazyrouter。

默认接入地址：

```text
https://cn.crazyrouter.com/v1
```

脚本会把 Crazyrouter API Key 和 Base URL 写入 Hermes 的本地配置目录：

```text
~/.hermes/.env
~/.hermes/config.yaml
```

> API Key 只写入本机配置文件，不会上传到其它地方。

---

## Linux / macOS / WSL2

如果机器上已经安装 Hermes Agent，用轻量配置脚本：

```bash
curl -fsSL https://raw.githubusercontent.com/xujfcn/crazyrouter-hermes/main/setup.sh | bash
```

如果是全新服务器/干净系统，用完整安装脚本。它会从系统环境检查开始，安装基础依赖，安装 Hermes Agent，再写入 Crazyrouter 配置，并可选测试 API 连接：

```bash
curl -fsSL https://raw.githubusercontent.com/xujfcn/crazyrouter-hermes/main/setup-full.sh | bash
```

非交互模式：

```bash
CRAZYROUTER_API_KEY=sk-your-key \
  bash <(curl -fsSL https://raw.githubusercontent.com/xujfcn/crazyrouter-hermes/main/setup-full.sh) \
  --yes --model claude-opus-4-8
```

脚本会提示输入 Crazyrouter API Key，并让你选择默认模型。

---

## Windows PowerShell

```powershell
irm https://raw.githubusercontent.com/xujfcn/crazyrouter-hermes/main/setup.ps1 | iex
```

如果 PowerShell 执行策略拦截，可以先下载脚本后本地运行。

---

## Windows CMD

```cmd
curl -o setup.bat https://raw.githubusercontent.com/xujfcn/crazyrouter-hermes/main/setup.bat
setup.bat
```

---

## 手动配置

在 `~/.hermes/.env` 中写入：

```env
CRAZYROUTER_API_KEY=sk-your-crazyrouter-key
```

Claude 必须使用 Anthropic Messages 原生协议：

```yaml
model:
  provider: "custom"
  default: "claude-opus-4-8"
  base_url: "https://cn.crazyrouter.com"
  api_mode: "anthropic_messages"
```

非 Claude 模型使用 OpenAI-compatible Chat Completions：

```yaml
model:
  provider: "custom"
  default: "gpt-5.5"
  base_url: "https://cn.crazyrouter.com/v1"
  api_mode: "chat_completions"
```

Claude 不应配置为 `codex_responses`，也不能请求 `/v1/responses`。在 Claude 和非 Claude 模型族之间切换时，请重新运行安装脚本，让 Hermes 同时更新 Base URL 和 `api_mode`。

---
## 默认模型

脚本会让你选择默认模型，常用示例：

```text
claude-opus-4-8
gpt-5.5
claude-opus-4-7
gpt-5.4
claude-sonnet-4-6
gemini-3.1-pro
deepseek-v4-flash
gpt-4o
```

进入 Hermes 后，也可以用 `/model` 命令切换模型：

```text
/model claude-opus-4-8
/model gpt-5.5
/model gpt-5.4
/model claude-opus-4-7
/model deepseek-v4-flash
```

---

## 脚本会做什么

### `setup.sh` 轻量配置脚本

- 创建 `~/.hermes` 目录（如果不存在）
- 写入 `OPENAI_API_KEY`
- 写入 `OPENAI_BASE_URL=https://cn.crazyrouter.com/v1`
- 生成或更新 `config.yaml`
- 覆盖旧配置前生成 `.bak` 备份
- 可选测试 API 连接

### `setup-full.sh` 完整安装脚本

- 识别 Linux / macOS / WSL2 环境
- 检查 `curl`、`git`、`python3`、`venv` 等基础依赖
- 支持 apt / dnf / yum / pacman / zypper / Homebrew 安装依赖
- 调用 Hermes 官方 installer 安装 Hermes Agent
- 跳过 Hermes 官方交互配置，统一写入 Crazyrouter 配置
- 支持 `--yes`、`--api-key`、`--model`、`--skip-deps`、`--skip-test` 等参数

---

## 常见问题

### 1. 为什么要用 `/v1`？

非 Claude 模型使用 OpenAI-compatible API，Base URL 以 `/v1` 结尾；Claude 使用 Anthropic Messages，Base URL 不带 `/v1`，Hermes 会请求 `/v1/messages`。

正确：

```text
https://cn.crazyrouter.com/v1
```

不建议写成：

```text
https://cn.crazyrouter.com
```

### 2. API Key 会上传吗？

不会。脚本只写入本地 Hermes 配置文件。

### 3. 配置错了怎么恢复？

脚本会备份旧文件，例如：

```text
~/.hermes/.env.bak
~/.hermes/config.yaml.bak
```

把备份文件改回原名即可恢复。

### 4. 如何确认配置生效？

重新打开 Hermes 后，运行：

```text
/model gpt-5.4
```

然后发送一个简单问题测试。

---

## 相关链接

- Crazyrouter: https://cn.crazyrouter.com
- Docs: https://docs.crazyrouter.com
- Hermes Agent: https://github.com/NousResearch/hermes-agent
