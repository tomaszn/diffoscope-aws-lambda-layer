import unittest

from diffoscoping import calculate


def run(event, context):
    unittest.TextTestRunner().run(
        unittest.TestLoader().loadTestsFromTestCase(ChromeExtensionTestCase)
    )


class ChromeExtensionTestCase(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        report_file = "/tmp/out.html"
        calculate(
            [
                "test/extension_2020_1_7_1.crx",
                "test/extension_2020_1_13_0.crx",
                "--text",
                report_file,
            ]
        )
        with open(report_file) as f:
            cls.report = f.read()

    def test_no_fallbacks(self):
        self.assertNotIn("Falling back", self.__class__.report)

    def test_jsonlike_manifest(self):
        self.assertIn("2020.1.7.1", self.__class__.report)

    def test_no_tools_missing(self):
        self.assertNotIn("missing", self.__class__.report)
