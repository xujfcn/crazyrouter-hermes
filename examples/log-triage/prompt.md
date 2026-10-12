Read examples/log-triage/events.jsonl in this repository. These are synthetic events, not customer logs.

Write a JSON array to a new local file named triage.json. Each object must contain id, category, next_step and retry. Cover every input ID once, without extra IDs.

Use these categories: credentials for 401; request_schema for 400; throttling for 429; model_or_route for 404; upstream for 5xx. retry must be false for credentials, request_schema and model_or_route, and true for throttling or upstream. A true value means a bounded retry may be appropriate after checking Retry-After, quota, idempotency and whether a chargeable job was already created; it does not authorize executing retries.

For each event, explain a concrete next check using its status, error_code and protocol. Do not claim a root cause is proven solely by HTTP status. Do not read credentials, send network requests, change configuration, or contact anyone. If you cannot read or write files, output the JSON so the user can save it.

Validate the saved result with: python examples/log-triage/validate.py triage.json
