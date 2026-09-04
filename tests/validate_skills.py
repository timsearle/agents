#!/usr/bin/env python3
"""Perform dependency-free structural checks on every bundled agent skill."""

from pathlib import Path
import re
import sys
from typing import Optional


ROOT = Path(__file__).resolve().parent.parent
SKILLS = ROOT / "skills"
NAME_PATTERN = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")


def frontmatter(text: str, path: Path) -> str:
    lines = text.splitlines()
    if not lines or lines[0] != "---":
        raise ValueError(f"{path}: missing opening YAML delimiter")
    try:
        end = lines.index("---", 1)
    except ValueError as error:
        raise ValueError(f"{path}: missing closing YAML delimiter") from error
    return "\n".join(lines[1:end])


def scalar(metadata: str, key: str) -> Optional[str]:
    match = re.search(rf"^{re.escape(key)}:\s*([^>|].*)$", metadata, re.MULTILINE)
    return match.group(1).strip().strip('"\'') if match else None


def main() -> int:
    failures: list[str] = []
    skill_directories = sorted(path for path in SKILLS.iterdir() if path.is_dir())

    for directory in skill_directories:
        path = directory / "SKILL.md"
        if not path.is_file():
            failures.append(f"{directory}: missing SKILL.md")
            continue

        try:
            metadata = frontmatter(path.read_text(encoding="utf-8"), path)
        except ValueError as error:
            failures.append(str(error))
            continue

        name = scalar(metadata, "name")
        if name != directory.name:
            failures.append(f"{path}: name must match directory ({directory.name})")
        elif not NAME_PATTERN.fullmatch(name):
            failures.append(f"{path}: invalid skill name {name!r}")

        if not re.search(r"^description:\s*(?:\S|[>|]\s*$)", metadata, re.MULTILINE):
            failures.append(f"{path}: missing description")

    if failures:
        print("\n".join(failures), file=sys.stderr)
        return 1

    print(f"Validated {len(skill_directories)} skills.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
