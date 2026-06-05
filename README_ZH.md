# Crazyrouter × Hermes Agent 一键配置说明

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

```bash
curl -fsSL https://raw.githubusercontent.com/xujfcn/crazyrouter-hermes/main/setup.sh | bash
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

如果你想手动配置，可以编辑：

```text
~/.hermes/.env
```

写入：

```env
OPENAI_API_KEY=sk-your-crazyrouter-key
OPENAI_BASE_URL=https://cn.crazyrouter.com/v1
```

然后编辑：

```text
~/.hermes/config.yaml
```

写入或更新：

```yaml
model:
  provider: "custom"
  default: "claude-opus-4-8"
  base_url: "https://cn.crazyrouter.com/v1"
```

---

## 默认模型

脚本会让你选择默认模型，常用示例：

```text
claude-opus-4-8
gpt-5.5
claude-opus-4-7
gpt-5.4
claude-sonnet-4.6
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

- 创建 `~/.hermes` 目录（如果不存在）
- 写入 `OPENAI_API_KEY`
- 写入 `OPENAI_BASE_URL=https://cn.crazyrouter.com/v1`
- 生成或更新 `config.yaml`
- 覆盖旧配置前生成 `.bak` 备份
- 可选测试 API 连接

---

## 常见问题

### 1. 为什么要用 `/v1`？

Hermes 使用 OpenAI-compatible API 形状，Base URL 通常需要以 `/v1` 结尾。

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
