"""Validate coverage and triage categories; this does not grade explanation quality."""
import json,sys
from pathlib import Path
EXPECTED={'sample-01':('credentials',False),'sample-02':('request_schema',False),'sample-03':('throttling',True),'sample-04':('model_or_route',False),'sample-05':('upstream',True)}
def validate(rows):
    if not isinstance(rows,list) or len(rows)!=len(EXPECTED):raise ValueError('Expected five events')
    seen=set()
    for row in rows:
        key=row.get('id')
        if key in seen or key not in EXPECTED:raise ValueError('Duplicate or unknown event')
        seen.add(key);category,retry=EXPECTED[key]
        if row.get('category')!=category or row.get('retry')is not retry:raise ValueError('Incorrect category or retry policy')
        if not isinstance(row.get('next_step'),str) or len(row['next_step'].strip())<20:raise ValueError('Provide a concrete next step')
    return {'events':len(rows),'coverage':'pass','categories':'pass','explanation_quality':'manual review required'}
if __name__=='__main__':
    try:print(json.dumps(validate(json.loads(Path(sys.argv[1]).read_text(encoding='utf-8')))))
    except (ValueError,KeyError,IndexError,OSError,AttributeError):print('Invalid result. Check coverage, categories and next steps.');raise SystemExit(1)
