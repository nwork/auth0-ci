#!/usr/bin/env python

import json
import unittest
import os

from unittest.mock import patch
#from mymodule import myclass

class SampleTest(unittest.TestCase):
    def setUp(self):
        # Anything you need to setup ahead of time for your `test_*` methods
        # `make test` will auto-discover and run all metehods starting with `test_`
        pass

# Example test with patched method
#    @patch.object(MyClass, "mymethod")
#    def test_sample(self, mock_mymethod):
#        fix_path = os.path.join(os.path.abspath(os.path.dirname(__file__)), 'data/sample.json')
#        with open(fix_path) as fd:
#            fix = json.load(fd)
#
#        mock_mymethod.return_value = fix
#        assert(True)
