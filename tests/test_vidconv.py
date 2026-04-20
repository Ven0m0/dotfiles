import importlib.util
import pathlib
import pytest

# Load the script as a module
script_path = pathlib.Path("Home/.local/bin/vidconv.py")
spec = importlib.util.spec_from_file_location("vidconv", script_path)
vidconv = importlib.util.module_from_spec(spec)
spec.loader.exec_module(vidconv)

def test_build_params_av1():
    cfg = vidconv.Config(
        crf=26,
        preset=3,
        preset_name="slow",
        grain=6,
        audio_bitrate="128k",
        audio_channels=2,
        pix_fmt="yuv420p10le",
        keyint=600,
        fast_decode=False,
        default_denoise=False,
        default_deband=False,
    )
    preset = vidconv.PRESETS["av1"]

    params = vidconv.build_params(preset, cfg)

    assert "-c:v" in params
    assert "libsvtav1" in params
    assert "-crf" in params
    assert "26" in params

    # Check format interpolation
    assert "-svtav1-params" in params
    svt_params_idx = params.index("-svtav1-params") + 1
    svt_params = params[svt_params_idx]
    assert "film-grain=6" in svt_params
    assert "fast-decode" not in svt_params

def test_build_params_with_fast_decode():
    cfg = vidconv.Config(crf=30, grain=4, fast_decode=True, default_denoise=False, default_deband=False)
    preset = vidconv.PRESETS["av1"]

    params = vidconv.build_params(preset, cfg)

    svt_params_idx = params.index("-svtav1-params") + 1
    svt_params = params[svt_params_idx]
    assert ":fast-decode=1" in svt_params

def test_build_params_video_filters():
    cfg = vidconv.Config(
        default_denoise=True,
        denoise="nlmeans",
        denoise_strength="light",
        default_deband=True,
        pix_fmt="yuv420p"
    )
    preset = vidconv.PRESETS["h265"]

    params = vidconv.build_params(preset, cfg)

    assert "-vf" in params
    vf_idx = params.index("-vf") + 1
    vf_str = params[vf_idx]

    # Check that filters are merged properly
    assert "nlmeans=h=4" in vf_str
    assert "deband" in vf_str
    assert "format=yuv420p" in vf_str

def test_build_params_extra_args():
    cfg = vidconv.Config(extra=["-map", "0:v", "-map", "0:a"])
    preset = vidconv.PRESETS["vp9"]

    params = vidconv.build_params(preset, cfg)

    # Extra args should be appended
    assert params[-4:] == ["-map", "0:v", "-map", "0:a"]

def test_build_params_audio_preset():
    cfg = vidconv.Config(audio_bitrate="192k")
    preset = vidconv.PRESETS["opus"]

    params = vidconv.build_params(preset, cfg)

    assert "-vf" not in params  # No video filters for audio
    assert "-c:a" in params
    assert "libopus" in params
    assert "-b:a" in params
    assert "192k" in params
