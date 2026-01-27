import unittest
from lambda_utils import findTerminatorIdcs

class TerminatorIdcsShould(unittest.TestCase):
    def test_return_empty_array_for_empty_string(self):
        terminatorIdcs = findTerminatorIdcs("")
        self.assertEqual(terminatorIdcs, [])

    def test_return_empty_array_for_non_terminating_string(self):
        terminatorIdcs = findTerminatorIdcs("nio[vron903u90t2niowv")
        self.assertEqual(terminatorIdcs, [])

    def test_return_empty_array_for_non_terminating_terminators_string(self):
        terminatorIdcs = findTerminatorIdcs('vow...vniw"vw"""p')
        self.assertEqual(terminatorIdcs, [])
