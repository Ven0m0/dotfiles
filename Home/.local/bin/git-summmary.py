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


def run_cmd(cmd: list[str] | str, cwd: Path) -> str:
    """Run command, return stdout or empty string on error."""
    try:
        is_shell = isinstance(cmd, str)
        return sp.run(
            cmd if is_shell else ["git", *cmd],
            cwd=cwd,
            capture_output=True,
            text=True,
            timeout=15,
            check=True,
            shell=is_shell,
        ).stdout.strip()
    except (sp.CalledProcessError, sp.TimeoutExpired, FileNotFoundError):
        return ""


def get_repo_stats(repo: Path) -> RepoStats:
    """Extract stats from a single git repo."""
    script = (
        "git ls-files | wc -l; "
        "if git rev-parse HEAD >/dev/null 2>&1; then "
        "  git rev-list --count HEAD; "
        "  git log -1 --format=%at; "
        "  git log --reverse -1 --format=%at; "
        "  git shortlog -sn HEAD; "
        "fi"
    )
    out = run_cmd(script, repo)
    if not out:
        return RepoStats(0, 0, 0, 0, {})

    lines = out.splitlines()
    files = int(lines[0]) if lines else 0
    if len(lines) < 4:
        return RepoStats(0, files, 0, 0, {})

    commits = int(lines[1])
    last_ts = int(lines[2])
    first_ts = int(lines[3])

    now = int(time())
    age = (now - first_ts) // 86400
    active = (now - last_ts) // 86400

    authors: dict[str, int] = {}
    for line in lines[4:]:
        line = line.strip()
        if not line:
            continue
        parts = line.split(None, 1)
        if len(parts) == 2:
            authors[parts[1]] = int(parts[0])
    return RepoStats(commits, files, age, active, authors)


def find_repos(path: Path) -> list[Path]:
    """Recursively find all git repositories."""
    repos: list[Path] = []
    for root, dirs, _ in os.walk(path):
        if ".git" in dirs:
            repo_path = Path(root)
            repos.append(repo_path)
            print(f"Git repository found {repo_path}", file=sys.stderr)
            dirs[:] = []  # Don't recurse into subdirectories
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

    def fmt_day(d):
        return "N/A" if d is None else f"{d} day{'s' if d != 1 else ''}"

    print(f"\nbase directory                  : {base}")
    print(f"repo age (latest / oldest)      : {fmt_day(min_age)} / {fmt_day(max_age)}")
    print(
        f"active (earliest / most recent) : {fmt_day(min_active)} / {fmt_day(max_active)}"
    )
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
