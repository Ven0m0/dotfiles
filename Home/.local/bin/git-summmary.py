#!/usr/bin/env python3
"""Recursively summarize git repositories in a directory tree."""
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
  commits_out = run_git(["rev-list", "--count", "HEAD"], repo)
  commits = int(commits_out) if commits_out else 0
  files_out = run_git(["ls-files"], repo)
  files = len(files_out.splitlines()) if files_out else 0
  first_ts = run_git(["log", "--reverse", "--format=%at", "--max-count=1"], repo)
  last_ts = run_git(["log", "--format=%at", "--max-count=1"], repo)
  now = int(time())
  age = (now - int(first_ts)) // 86400 if first_ts else 0
  active = (now - int(last_ts)) // 86400 if last_ts else 0
  authors: dict[str, int] = defaultdict(int)
  authors_out = run_git(["shortlog", "-s", "HEAD"], repo)
  for line in authors_out.splitlines():
    line = line.strip()
    if not line:
      continue
    parts = line.split("\t", 1)
    if len(parts) == 2:
      count, author = parts
      authors[author] += int(count)
  return RepoStats(commits, files, age, active, dict(authors))

def find_repos(path: Path) -> list[Path]:
  """Recursively find all git repositories."""
  repos: list[Path] = []
  try:
    for item in path.iterdir():
      if item.is_dir():
        if (item / ".git").is_dir():
          repos.append(item)
          print(f"Git repository found {item}", file=sys.stderr)
        else:
          repos.extend(find_repos(item))
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
  for repo in repos:
    stats = get_repo_stats(repo)
    total_commits += stats.commits
    total_files += stats.files
    age, active = stats.age, stats.active
    min_age = age if min_age is None else min(min_age, age)
    max_age = age if max_age is None else max(max_age, age)
    min_active = active if min_active is None else min(min_active, active)
    max_active = active if max_active is None else max(max_active, active)
    for author, count in stats.authors.items():
      all_authors[author] += count
  fmt_day = lambda d: f"{d} day{'s' if d != 1 else ''}"
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
