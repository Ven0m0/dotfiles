import importlib.util
import sys
from pathlib import Path

# Import vidconv.py as a module
spec = importlib.util.spec_from_file_location("vidconv", str(Path("Home/.local/bin/vidconv.py").resolve()))
vidconv = importlib.util.module_from_spec(spec)
sys.modules["vidconv"] = vidconv
spec.loader.exec_module(vidconv)

Config = vidconv.Config
build_filters = vidconv.build_filters

def test_build_filters_non_video():
    cfg = Config()
    filters = build_filters(cfg, is_video=False)
    assert filters == []

def test_build_filters_default():
    cfg = Config()
    filters = build_filters(cfg, is_video=True)
    # default_denoise is True, denoise=None -> hqdn3d=1.5:1.5:6:6
    # max_dim=(1920, 1080) -> scale
    # default_deband is True -> deband
    # pix_fmt="yuv420p10le"
    assert len(filters) == 4
    assert filters[0] == "hqdn3d=1.5:1.5:6:6"
    assert "scale=" in filters[1]
    assert filters[2] == "deband"
    assert filters[3] == "format=yuv420p10le"

def test_build_filters_deinterlace():
    cfg = Config(deinterlace="bwdif", default_denoise=False, default_deband=False, max_dim=None)
    filters = build_filters(cfg, is_video=True)
    assert filters[0] == "bwdif=mode=send_frame:parity=auto:deint=all"

    cfg = Config(deinterlace="yadif", default_denoise=False, default_deband=False, max_dim=None)
    filters = build_filters(cfg, is_video=True)
    assert filters[0] == "yadif=mode=send_frame:parity=auto:deint=all"

    cfg = Config(deinterlace="decomb", default_denoise=False, default_deband=False, max_dim=None)
    filters = build_filters(cfg, is_video=True)
    assert filters[0] == "yadif=mode=send_field:parity=auto"

def test_build_filters_denoise():
    cfg = Config(denoise="nlmeans", denoise_strength="light", default_deband=False, max_dim=None)
    filters = build_filters(cfg, is_video=True)
    assert filters[0] == "nlmeans=h=4"

    cfg = Config(denoise="nlmeans", denoise_strength="strong", default_deband=False, max_dim=None)
    filters = build_filters(cfg, is_video=True)
    assert filters[0] == "nlmeans=h=8"

    cfg = Config(denoise="hqdn3d", denoise_strength="ultralight", default_deband=False, max_dim=None)
    filters = build_filters(cfg, is_video=True)
    assert filters[0] == "hqdn3d=2"

def test_build_filters_deblock():
    cfg = Config(deblock="weak", default_denoise=False, default_deband=False, max_dim=None)
    filters = build_filters(cfg, is_video=True)
    assert "deblock=weak" in filters

def test_build_filters_rotate():
    cfg = Config(rotate=90, default_denoise=False, default_deband=False, max_dim=None)
    filters = build_filters(cfg, is_video=True)
    assert "transpose=1" in filters

    cfg = Config(rotate=180, default_denoise=False, default_deband=False, max_dim=None)
    filters = build_filters(cfg, is_video=True)
    assert "transpose=1,transpose=1" in filters

    cfg = Config(rotate=270, default_denoise=False, default_deband=False, max_dim=None)
    filters = build_filters(cfg, is_video=True)
    assert "transpose=2" in filters

def test_build_filters_crop_scale():
    cfg = Config(crop="auto", default_denoise=False, default_deband=False, max_dim=None)
    filters = build_filters(cfg, is_video=True)
    assert "cropdetect=24:16:0" in filters

    cfg = Config(crop="1920:1080:0:0", default_denoise=False, default_deband=False, max_dim=None)
    filters = build_filters(cfg, is_video=True)
    assert "crop=1920:1080:0:0" in filters

    cfg = Config(scale="1280:-2", default_denoise=False, default_deband=False, max_dim=None)
    filters = build_filters(cfg, is_video=True)
    assert "scale=1280:-2:flags=lanczos" in filters

def test_build_filters_none_off():
    cfg = Config(deinterlace="off", denoise="off", deblock="off", crop="off", default_denoise=False, default_deband=False, max_dim=None)
    filters = build_filters(cfg, is_video=True)
    assert filters == ["format=yuv420p10le"]
