import importlib.util,unittest
from pathlib import Path
spec=importlib.util.spec_from_file_location('validate',Path(__file__).parents[1]/'examples/log-triage/validate.py');v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v)
def valid():return [{'id':key,'category':cat,'retry':retry,'next_step':'Inspect the exact error code and protocol before proceeding.'}for key,(cat,retry)in v.EXPECTED.items()]
class TriageTests(unittest.TestCase):
    def test_complete(self):self.assertEqual(v.validate(valid())['events'],5)
    def test_duplicate_and_wrong_retry(self):
        rows=valid();rows[-1]=rows[0]
        with self.assertRaises(ValueError):v.validate(rows)
        rows=valid();rows[0]['retry']=True
        with self.assertRaises(ValueError):v.validate(rows)
    def test_short_explanation(self):
        rows=valid();rows[0]['next_step']='retry'
        with self.assertRaises(ValueError):v.validate(rows)
if __name__=='__main__':unittest.main()
