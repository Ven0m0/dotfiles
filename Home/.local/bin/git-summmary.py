#!/usr/bin/env python3
"""Recursively summarize git repositories in a directory tree."""

import os
import subprocess as sp
import sys
from collections import defaultdict
from concurrent.futures import ThreadPoolExecutor
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


def get_repo_stats(repo: Path) -> RepoStats:
    """Extract stats from a single git repo."""
    cmd = ["sh", "-c", "git ls-files 2>/dev/null | wc -l; printf '\\0'; git log --format='%at%x00%aN%x00%P' HEAD 2>/dev/null || true"]
    try:
        proc = sp.run(
            cmd,
            cwd=repo,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=10,
        )
        out = proc.stdout
    except (sp.CalledProcessError, sp.TimeoutExpired, FileNotFoundError, OSError):
        return RepoStats(0, 0, 0, 0, {})

    parts = out.split("\x00", 1)
    if len(parts) != 2:
        return RepoStats(0, 0, 0, 0, {})

    try:
        files = int(parts[0].strip())
    except ValueError:
        files = 0

    commits = 0
    last_ts = 0
    root_timestamps: list[int] = []
    authors: dict[str, int] = defaultdict(int)

    for i, line in enumerate(parts[1].splitlines()):
        line = line.strip()
        if not line:
            continue
        line_parts = line.split("\x00")
        if len(line_parts) < 3:
            continue

        try:
            ts = int(line_parts[0])
        except ValueError:
            continue

        author = line_parts[1]
        parents = line_parts[2]

        if i == 0:
            last_ts = ts

        if not parents:
            root_timestamps.append(ts)

        commits += 1
        authors[author] += 1

    if commits == 0:
        return RepoStats(0, files, 0, 0, {})

    first_ts = min(root_timestamps) if root_timestamps else last_ts

    now = int(time())
    age = (now - first_ts) // 86400
    active = (now - last_ts) // 86400

    return RepoStats(commits, files, age, active, authors)


def find_repos(path: Path) -> list[Path]:
    """Recursively find all git repositories."""
    repos: list[Path] = []
    try:
        cmd = ["find", "-L", str(path), "-name", ".git", "-type", "d", "-prune"]
        proc = sp.run(cmd, capture_output=True, text=True, check=True)
        for line in proc.stdout.splitlines():
            repo = Path(line).parent
            if repo != path:
                repos.append(repo)
                print(f"Git repository found {repo}", file=sys.stderr)
        return repos
    except (sp.CalledProcessError, FileNotFoundError, OSError):
        # Fallback to os.walk if find is not available or errors out
        pass

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
    with ThreadPoolExecutor() as executor:
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
        return f"{d} day{'s' if d != 1 else ''}"

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
