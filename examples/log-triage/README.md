# Local log triage with an acceptance check

This workflow is designed for Hermes but has not been run in a full Hermes interactive session in this release. Inputs are synthetic. No production credentials or network tools are needed.

1. Clone the repository and start your configured Hermes session in its directory.
2. Give it the contents of [prompt.md](prompt.md). The agent reads five fixture events and writes triage.json; if file tools are unavailable, save its JSON output yourself.
3. Run `python examples/log-triage/validate.py triage.json` from the repository root.
4. Manually inspect next_step: it should distinguish the status from a proven cause and propose a concrete check. The validator checks coverage/categories/retry policy, not explanation quality.

Expected categories: sample-01 credentials; sample-02 request_schema; sample-03 throttling; sample-04 model_or_route; sample-05 upstream. Every ID appears once. No key values, raw customer prompts or external messages should appear in the result.

A permitted retry category is advisory. For asynchronous jobs, verify whether the first submission already created a task. Do not retry non-idempotent billable work blindly.

Switching between Claude and other model families can require both protocol and base URL changes. Use the repository setup guide and the [protocol doctor](https://github.com/xujfcn/claude-opus-4.5-gpt-5.2/blob/main/docs/start-here.md) to isolate connectivity before debugging an Agent workflow.

中文：把 prompt.md 交给 Hermes，使用固定样例产生 triage.json，再跑验收命令。样例是合成日志；验证器只查覆盖率、分类和重试规则，解释质量需人工审阅。当前不宣称已完成 Hermes 全客户端端到端实测。
