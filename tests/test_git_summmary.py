import importlib.util
import os
import pathlib
import subprocess

# Load the script as a module
repo_root = pathlib.Path(__file__).resolve().parents[1]
script_path = repo_root / "Home/.local/bin/git-summmary.py"
spec = importlib.util.spec_from_file_location("git_summmary", script_path)
if spec is None or spec.loader is None:
    raise ImportError(f"Unable to load module from {script_path}")
git_summmary = importlib.util.module_from_spec(spec)
spec.loader.exec_module(git_summmary)

def run_git(cmd, cwd, env=None):
    env_merged = os.environ.copy()
    if env:
        env_merged.update(env)
    # Set default user config to avoid issues in empty environments
    env_merged["GIT_AUTHOR_NAME"] = env_merged.get("GIT_AUTHOR_NAME", "Test User")
    env_merged["GIT_AUTHOR_EMAIL"] = env_merged.get("GIT_AUTHOR_EMAIL", "test@example.com")
    env_merged["GIT_COMMITTER_NAME"] = env_merged.get("GIT_COMMITTER_NAME", "Test User")
    env_merged["GIT_COMMITTER_EMAIL"] = env_merged.get("GIT_COMMITTER_EMAIL", "test@example.com")

    subprocess.run(["git"] + cmd, cwd=cwd, env=env_merged, check=True, capture_output=True)

def test_get_repo_stats_invalid_repo(tmp_path):
    stats = git_summmary.get_repo_stats(tmp_path)
    assert stats.commits == 0
    assert stats.files == 0
    assert stats.authors == {}

def test_get_repo_stats_empty_repo(tmp_path):
    run_git(["init"], cwd=tmp_path)
    stats = git_summmary.get_repo_stats(tmp_path)
    assert stats.commits == 0
    assert stats.files == 0

def test_get_repo_stats_commits(tmp_path, monkeypatch):
    run_git(["init"], cwd=tmp_path)

    # Mock current time to exactly 100 days after first commit
    # Let's say first commit is at 1000000000
    base_time = 1000000000

    # Commit 1
    (tmp_path / "file1.txt").write_text("hello")
    run_git(["add", "file1.txt"], cwd=tmp_path)
    run_git(["commit", "-m", "first"], cwd=tmp_path, env={"GIT_AUTHOR_DATE": f"{base_time} +0000", "GIT_COMMITTER_DATE": f"{base_time} +0000", "GIT_AUTHOR_NAME": "Alice"})

    # Commit 2 (20 days later)
    (tmp_path / "file2.txt").write_text("world")
    run_git(["add", "file2.txt"], cwd=tmp_path)
    run_git(["commit", "-m", "second"], cwd=tmp_path, env={"GIT_AUTHOR_DATE": f"{base_time + 86400 * 20} +0000", "GIT_COMMITTER_DATE": f"{base_time + 86400 * 20} +0000", "GIT_AUTHOR_NAME": "Bob"})

    # Mock time.time() to exactly base_time + 100 days
    monkeypatch.setattr(git_summmary, "time", lambda: base_time + 86400 * 100)

    stats = git_summmary.get_repo_stats(tmp_path)

    assert stats.commits == 2
    assert stats.files == 2
    assert stats.age == 100
    assert stats.active == 80  # 100 days - 20 days
    assert dict(stats.authors) == {"Alice": 1, "Bob": 1}
