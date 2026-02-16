#!/usr/bin/env python3
"""Recursively summarize git repositories in a directory tree."""
import concurrent.futures
import os
import subprocess as sp
import sys
from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path
from time import time

@dataclass(slots=True)
class RepoStats:
  commits: int
  files: int
  age: int
  active: int
  authors: dict[str, int]

def run_git(cmd: list[str], cwd: Path) -> str:
  """Run git command, return stdout or empty string on error."""
  try:
    return sp.run(
      ["git", *cmd],
      cwd=cwd,
      capture_output=True,
      text=True,
      timeout=10,
      check=True
    ).stdout.strip()
  except (sp.CalledProcessError, sp.TimeoutExpired, FileNotFoundError):
    return ""

def get_repo_stats(repo: Path) -> RepoStats:
  """Extract stats from a single git repo."""
  files_out = run_git(["ls-files"], repo)
  files = len(files_out.splitlines()) if files_out else 0

  commits_str = run_git(["rev-list", "--count", "HEAD"], repo)
  if not commits_str:
    return RepoStats(0, files, 0, 0, {})
  commits = int(commits_str)

  last_ts_str = run_git(["log", "-1", "--format=%at", "HEAD"], repo)
  last_ts = int(last_ts_str) if last_ts_str else 0

  # Get oldest commit timestamp (handle multiple roots)
  roots_out = run_git(["log", "--max-parents=0", "--format=%at", "HEAD"], repo)
  if roots_out:
    first_ts = min(int(ts) for ts in roots_out.splitlines() if ts.strip())
  else:
    first_ts = last_ts

  now = int(time())
  age = (now - first_ts) // 86400
  active = (now - last_ts) // 86400

  authors: dict[str, int] = {}
  authors_out = run_git(["shortlog", "-sn", "HEAD"], repo)
  if authors_out:
    for line in authors_out.splitlines():
      line = line.strip()
      if not line: continue
      parts = line.split('\t', 1)
      if len(parts) == 2:
        authors[parts[1]] = int(parts[0])
      else:
        parts = line.split(None, 1)
        if len(parts) == 2:
          authors[parts[1]] = int(parts[0])

  return RepoStats(commits, files, age, active, authors)

def find_repos(path: Path) -> list[Path]:
  """Recursively find all git repositories."""
  repos: list[Path] = []
  try:
    for dirpath, dirnames, filenames in os.walk(path, followlinks=True):
      if ".git" in dirnames:
        dirnames.remove(".git")
        repo = Path(dirpath)
        if repo != path:
          repos.append(repo)
          print(f"Git repository found {repo}", file=sys.stderr)
          dirnames[:] = []
  except PermissionError:
    pass
  return repos

def aggregate_stats(repos: list[Path], base: Path) -> None:
  """Aggregate stats from all repos and display."""
  if not repos:
    print("Git repository is not found in directory scan", file=sys.stderr)
    return
  total_commits = total_files = 0
  min_age = max_age = min_active = max_active = None
  all_authors: dict[str, int] = defaultdict(int)
  with concurrent.futures.ThreadPoolExecutor() as executor:
    stats_list = list(executor.map(get_repo_stats, repos))

  for stats in stats_list:
    total_commits += stats.commits
    total_files += stats.files
    age, active = stats.age, stats.active
    min_age = age if min_age is None else min(min_age, age)
    max_age = age if max_age is None else max(max_age, age)
    min_active = active if min_active is None else min(min_active, active)
    max_active = active if max_active is None else max(max_active, active)
    for author, count in stats.authors.items():
      all_authors[author] += count
  def fmt_day(d): return f"{d} day{'s' if d != 1 else ''}"
  print(f"\nbase directory                  : {base}")
  print(f"repo age (latest / oldest)      : {fmt_day(min_age)} / {fmt_day(max_age)}")
  print(f"active (earliest / most recent) : {fmt_day(min_active)} / {fmt_day(max_active)}")
  print(f"commits                         : {total_commits}")
  print(f"files                           : {total_files}")
  print("authors                         :")
  if not all_authors:
    return
  max_cnt_len = max(len(str(c)) for c in all_authors.values())
  max_name_len = max(len(n) for n in all_authors)
  for author, count in sorted(all_authors.items(), key=lambda x: x[1]):
    pct = (count / total_commits) * 100 if total_commits else 0
    print(f"  {count:{max_cnt_len}}  {author:{max_name_len}}  {pct:.2f}")

if __name__ == "__main__":
  if len(sys.argv) != 2:
    sys.exit("Usage: git-summary <directory>")
  base_path = Path(sys.argv[1]).resolve()
  if not base_path.is_dir():
    sys.exit(f"Error: {base_path} is not a directory")
  repos = find_repos(base_path)
  aggregate_stats(repos, base_path)
