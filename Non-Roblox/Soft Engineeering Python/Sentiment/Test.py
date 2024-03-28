import unittest
from unittest.mock import patch

from sentiment import main


class TestMainFunction(unittest.TestCase):
    @patch('builtins.input', side_effect=['2', 'too', '8'])
    def test_main1(self, mock_input):
        with patch('builtins.print') as mock_print:
            result = main()
            assert result == (16444, None, None, None, None)

    @patch('builtins.input', side_effect=['3', 'Too', '8'])
    def test_main2(self, mock_input):
        with patch('builtins.print') as mock_print:
            result = main()
            assert result == (314, None, None, None, None)

    @patch('builtins.input', side_effect=['4', 'too', '8'])
    def test_main3(self, mock_input):
        with patch('builtins.print') as mock_print:
            result = main()
            assert result == (200, 65, 49, -1.4990477543373988, None)

    @patch('builtins.input', side_effect=['5', 'absolutely detestable ; would not watch again', '8'])
    def test_main4(self, mock_input):
        with patch('builtins.print') as mock_print:
            result = main()
            assert result == (5, 0, 1, 1, -0.18812093738509109)

    @patch('builtins.input', side_effect=['7', 'absolutely detestable ; would not watch again', '8'])
    def test_main5(self, mock_input):
        with patch('builtins.print') as mock_print:
            result = main()
            assert result == (4, 0, 1, 1, -0.17687684751966531)

    @patch('builtins.input', side_effect=['6', '8'])
    def test_main6(self, mock_input):
        with patch('builtins.print') as mock_print:
            result = main()
            assert result == (51, None, None, None, None)



if __name__ == '__main__':
    unittest.main()
