#!/usr/bin/env python3

"""Validate and summarize SILEX_THREADING_BENCHMARK records."""

from __future__ import annotations

import argparse
import math
import pathlib
import statistics
import sys
from collections import defaultdict


def load_records(paths: list[pathlib.Path]) -> list[dict[str, str]]:
    records: list[dict[str, str]] = []
    sources = [("<stdin>", sys.stdin)] if not paths else [
        (str(path), path.open(encoding="utf-8")) for path in paths
    ]
    try:
        for source, stream in sources:
            for line_number, raw_line in enumerate(stream, 1):
                line = raw_line.strip()
                prefix = "SILEX_THREADING_BENCHMARK "
                if not line.startswith(prefix):
                    continue
                record: dict[str, str] = {}
                for field in line[len(prefix) :].split():
                    if "=" not in field:
                        raise ValueError(f"{source}:{line_number}: malformed field {field!r}")
                    key, value = field.split("=", 1)
                    if key in record:
                        raise ValueError(f"{source}:{line_number}: duplicate field {key!r}")
                    record[key] = value
                required = {
                    "mode", "workers", "count", "rounds", "sequential_ms",
                    "parallel_ms", "ranges", "allocations", "checksum",
                }
                missing = sorted(required - record.keys())
                if missing:
                    raise ValueError(
                        f"{source}:{line_number}: missing fields: {', '.join(missing)}"
                    )
                for key in ("sequential_ms", "parallel_ms"):
                    if not math.isfinite(float(record[key])):
                        raise ValueError(f"{source}:{line_number}: {key} is not finite")
                records.append(record)
    finally:
        for _, stream in sources:
            if stream is not sys.stdin:
                stream.close()
    if not records:
        raise ValueError("no threading benchmark record found")
    return records


def summarize(records: list[dict[str, str]]) -> tuple[list[str], list[str]]:
    grouped: dict[tuple[int, int, int], list[dict[str, str]]] = defaultdict(list)
    failures: list[str] = []
    reports: list[str] = []
    for record in records:
        if record["mode"] != "release":
            failures.append(f"expected release mode, got {record['mode']!r}")
        key = (int(record["workers"]), int(record["count"]), int(record["rounds"]))
        grouped[key].append(record)

    workloads = {(count, rounds) for _, count, rounds in grouped}
    for count, rounds in sorted(workloads):
        workers = {worker_count for worker_count, grouped_count, grouped_rounds in grouped
                   if grouped_count == count and grouped_rounds == rounds}
        if workers != {1, 2, 4}:
            failures.append(
                f"count-{count}/rounds-{rounds}: expected workers 1, 2 and 4, got {sorted(workers)}"
            )
        checksums = {
            record["checksum"]
            for worker_count in workers
            for record in grouped[(worker_count, count, rounds)]
        }
        if len(checksums) != 1:
            failures.append(f"count-{count}/rounds-{rounds}: checksum changed across workers")

    largest_count = max(count for count, _ in workloads)
    medians: dict[tuple[int, int, int], float] = {}
    for key in sorted(grouped):
        workers, count, rounds = key
        group = grouped[key]
        if len(group) != 7:
            failures.append(
                f"workers-{workers}/count-{count}: expected 7 measured runs, got {len(group)}"
            )
        values = [float(record["parallel_ms"]) for record in group]
        median = statistics.median(values)
        mad = statistics.median(abs(value - median) for value in values)
        relative_mad = mad / median if median > 0.0 else math.inf
        medians[key] = median
        expected_ranges = workers * rounds
        if any(int(record["ranges"]) != expected_ranges for record in group):
            failures.append(
                f"workers-{workers}/count-{count}: range count is not one per worker and round"
            )
        if any(int(record["allocations"]) != 1 for record in group):
            failures.append(
                f"workers-{workers}/count-{count}: warmed batch allocation count is not one"
            )
        if count == largest_count and len(group) >= 7 and relative_mad > 0.05:
            failures.append(
                f"workers-{workers}/count-{count}: MAD {relative_mad * 100.0:.2f}% exceeds 5%"
            )
        reports.append(
            f"workers-{workers}/count-{count}: n={len(group)} "
            f"median={median:.6f}ms min={min(values):.6f}ms max={max(values):.6f}ms "
            f"mad={mad:.6f}ms ({relative_mad * 100.0:.2f}%)"
        )

    largest_count, largest_rounds = max(workloads)
    largest = [medians.get((workers, largest_count, largest_rounds)) for workers in (1, 2, 4)]
    if all(value is not None for value in largest):
        one, two, four = largest
        assert one is not None and two is not None and four is not None
        if not one > two > four:
            failures.append(
                f"count-{largest_count}: expected 1 > 2 > 4 worker medians, got "
                f"{one:.6f}, {two:.6f}, {four:.6f} ms"
            )
    return reports, failures


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("paths", nargs="*", type=pathlib.Path)
    parser.add_argument("--enforce", action="store_true")
    arguments = parser.parse_args()
    try:
        records = load_records(arguments.paths)
        reports, failures = summarize(records)
    except (OSError, ValueError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 2
    for report in reports:
        print(report)
    for failure in failures:
        print(f"FAIL: {failure}")
    return 1 if arguments.enforce and failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
