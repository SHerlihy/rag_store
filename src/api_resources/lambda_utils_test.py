import unittest
from lambda_utils import findTerminatedIdcs, splitByLineCount

class TerminatedIdcsShould(unittest.TestCase):
    def test_return_empty_array_for_empty_string(self):
        terminatorIdcs = findTerminatedIdcs("")
        self.assertEqual(terminatorIdcs, [])

    def test_return_empty_array_for_non_terminating_string(self):
        terminatorIdcs = findTerminatedIdcs("nio[vron903u90t2niowv")
        self.assertEqual(terminatorIdcs, [])

    def test_return_empty_array_for_non_terminating_terminators_string(self):
        terminatorIdcs = findTerminatedIdcs('vow...vniw"vw"""p')
        self.assertEqual(terminatorIdcs, [])

class TerminatedIdcsShouldReturnCorrectIdcs(unittest.TestCase):
    def test_for_period_string(self):
        terminatorIdcs = findTerminatedIdcs("0123. 67. 101112.")
        self.assertEqual(terminatorIdcs, [5,9])

    def test_for_punctuation_string(self):
        terminatorIdcs = findTerminatedIdcs("012? 5678! 12. 56?")
        self.assertEqual(terminatorIdcs, [4,10,14])

    def test_for_quotes_string(self):
        terminatorIdcs = findTerminatedIdcs('01234 "789"\n2345')
        self.assertEqual(terminatorIdcs, [12])

    def test_for_newline_string(self):
        terminatorIdcs = findTerminatedIdcs("012?\n5678!\n12.\n56?")
        self.assertEqual(terminatorIdcs, [5,11,15])

    def test_for_excess_string(self):
        sentances = [
            'vavvaniovwip.\n',
            'vavvaniovwip?\n',
            ]

        multi_punctuation = "".join(sentances)

        terminatorIdcs = findTerminatedIdcs(multi_punctuation)
        self.assertEqual(terminatorIdcs, [14, 28])

class SplitByLineCountShouldReturnStringArray(unittest.TestCase):
    def test_for_single_strings(self):
        sentances = [
            'vavvaniovwip.\n',
            'vavvaniovwip?\n',
            'vavvaniovwip!\n',
            'vavvanio "vwip"\n',
            'vavvaniovwip!\n',
            'vavvaniovwip?\n'
            ]

        multi_punctuation = "".join(sentances)

        segments = splitByLineCount(multi_punctuation, 1)
        
        print(segments)

        self.assertEqual(len(segments), len(sentances))

        self.assertEqual(segments, sentances)

    # def test_for_multi_punctuation(self):
    #     sentances = [
    #         'vavvaniovwip.\n',
    #         'vavvaniovwip?\n',
    #         'vavvaniovwip!\n',
    #         'vavvanio "vwip"\n',
    #         'vavvaniovwip!\n',
    #         'vavvaniovwip?\n'
    #         ]
    #
    #     multi_punctuation = "".join(sentances)
    #
    #     segments = splitByLineCount(multi_punctuation, 2)
    #
    #     self.assertEqual(len(segments), 3)
    #
    #     self.assertEqual(segments, [
    #         sentances[0]+sentances[1],
    #         sentances[2]+sentances[3],
    #         sentances[4]+sentances[5]
    #         ])
