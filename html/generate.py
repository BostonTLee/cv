#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "jinja2>=3.1,<4",
#     "pyyaml>=6.0,<7",
# ]
# ///

"""Render the CV YAML data as a standalone HTML document."""

from __future__ import annotations

import argparse
import sys
from datetime import date, datetime
from pathlib import Path
from typing import Any

import yaml
from jinja2 import Environment, FileSystemLoader, StrictUndefined, select_autoescape


MONTH_NAMES = (
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
)


def date_label(value: date | datetime | str) -> str:
    """Format an ISO date in the same abbreviated form as the Typst CV."""

    raw = value.isoformat() if isinstance(value, (date, datetime)) else str(value)
    parsed = date.fromisoformat(raw[:10])
    return f"{MONTH_NAMES[parsed.month - 1]} {parsed.year}"


def date_range(start: date | datetime | str, end: date | datetime | str | None = None) -> str:
    """Format a start/end range, using Present for an open-ended entry."""

    end_label = "Present" if end is None else date_label(end)
    return f"{date_label(start)} \N{EN DASH} {end_label}"


def description_content(item: Any) -> Any:
    """Get the display text from either supported YAML description shape."""

    return item.get("content", "") if isinstance(item, dict) else item


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "input",
        nargs="?",
        type=Path,
        default=Path("cv.yaml"),
        help="YAML CV input (default: cv.yaml)",
    )
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        help="HTML output path; write to stdout when omitted",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    template_dir = Path(__file__).resolve().parent

    with args.input.open(encoding="utf-8") as input_file:
        cv = yaml.safe_load(input_file)

    environment = Environment(
        loader=FileSystemLoader(template_dir),
        autoescape=select_autoescape(["html", "xml"]),
        undefined=StrictUndefined,
        trim_blocks=True,
        lstrip_blocks=True,
    )
    environment.filters["date_label"] = date_label
    environment.filters["description_content"] = description_content
    environment.globals.update(date_label=date_label, date_range=date_range)

    html = environment.get_template("template.html").render(cv=cv)
    if args.output is None:
        sys.stdout.write(html)
        return

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(html, encoding="utf-8")


if __name__ == "__main__":
    main()
