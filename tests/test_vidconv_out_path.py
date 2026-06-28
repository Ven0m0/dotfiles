import importlib.util
import pathlib
from pathlib import Path
import sys

# Load the script as a module
script_path = pathlib.Path("Home/.local/bin/vidconv.py").resolve()
spec = importlib.util.spec_from_file_location("vidconv", script_path)
vidconv = importlib.util.module_from_spec(spec)
sys.modules["vidconv"] = vidconv
spec.loader.exec_module(vidconv)


def test_gen_out_path_basic():
    inp = Path("/tmp/input/video.mp4")
    preset = vidconv.Preset(name="test", suffix=".test", params=(), ext="mkv")
    cfg = vidconv.Config()

    out = vidconv.gen_out_path(inp, preset, cfg, out_dir=None, src_root=None)

    assert out == Path("/tmp/input/video.test.mkv")


def test_gen_out_path_formatting():
    inp = Path("video.mp4")
    preset = vidconv.Preset(
        name="test", suffix=".crf{crf}-gr{grain}", params=(), ext="mkv"
    )
    cfg = vidconv.Config(crf=23, grain=4)

    out = vidconv.gen_out_path(inp, preset, cfg, out_dir=None, src_root=None)

    assert out == Path("video.crf23-gr4.mkv")


def test_gen_out_path_sanitization():
    inp = Path("video.mp4")
    # suffix with characters that should be stripped if not in ._-+ or alnum
    preset = vidconv.Preset(name="test", suffix=".test!@#$%", params=(), ext="mkv")
    cfg = vidconv.Config()

    out = vidconv.gen_out_path(inp, preset, cfg, out_dir=None, src_root=None)

    assert out == Path("video.test.mkv")


def test_gen_out_path_with_out_dir(tmp_path):
    inp = Path("/some/path/video.mp4")
    out_dir = tmp_path / "output"
    preset = vidconv.Preset(name="test", suffix=".test", params=(), ext="mkv")
    cfg = vidconv.Config()

    out = vidconv.gen_out_path(inp, preset, cfg, out_dir=out_dir, src_root=None)

    assert out == out_dir / "video.test.mkv"
    assert out_dir.exists()


def test_gen_out_path_with_out_dir_and_src_root(tmp_path):
    src_root = Path("/src")
    inp = src_root / "movies/action/video.mp4"
    out_dir = tmp_path / "dest"
    preset = vidconv.Preset(name="test", suffix=".test", params=(), ext="mkv")
    cfg = vidconv.Config()

    out = vidconv.gen_out_path(inp, preset, cfg, out_dir=out_dir, src_root=src_root)

    assert out == out_dir / "movies/action/video.test.mkv"
    assert (out_dir / "movies/action").exists()
