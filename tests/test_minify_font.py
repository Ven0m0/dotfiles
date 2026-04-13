import sys
import importlib.util
from unittest.mock import MagicMock
import pathlib
import pytest

# Pre-mock fontforge to allow importing the script
mock_fontforge_module = MagicMock()
sys.modules['fontforge'] = mock_fontforge_module

script_path = pathlib.Path("Home/.local/bin/minify_font.py")
spec = importlib.util.spec_from_file_location("minify_font", script_path)
minify_font = importlib.util.module_from_spec(spec)
spec.loader.exec_module(minify_font)

@pytest.fixture(autouse=True)
def reset_fontforge_mock():
    mock_fontforge_module.reset_mock()
    mock_fontforge_module.open.side_effect = None

def test_file_not_found(tmp_path):
    path = tmp_path / "missing.ttf"
    assert minify_font.minify_font(str(path)) == 1

def test_not_a_file(tmp_path):
    assert minify_font.minify_font(str(tmp_path)) == 1

def test_minify_font_success(tmp_path):
    mock_font = MagicMock()
    mock_fontforge_module.open.return_value = mock_font

    input_file = tmp_path / "test.ttf"
    input_file.touch()

    assert minify_font.minify_font(str(input_file)) == 0

    mock_fontforge_module.open.assert_called_once_with(str(input_file))
    assert mock_font.bitmaps is None
    mock_font.simplify.assert_called_once()

    output_path = tmp_path / "test_minified.ttf"
    mock_font.generate.assert_called_once_with(str(output_path), flags=("short-post", "no-hints", "no-flex"))
    mock_font.close.assert_called_once()

def test_minify_font_open_error(tmp_path):
    mock_fontforge_module.open.side_effect = OSError("Permission denied")

    input_file = tmp_path / "error.ttf"
    input_file.touch()

    assert minify_font.minify_font(str(input_file)) == 1

def test_minify_font_generate_error(tmp_path):
    mock_font = MagicMock()
    mock_font.generate.side_effect = OSError("Disk full")
    mock_fontforge_module.open.return_value = mock_font

    input_file = tmp_path / "test.ttf"
    input_file.touch()

    assert minify_font.minify_font(str(input_file)) == 1
    mock_font.close.assert_called_once()
