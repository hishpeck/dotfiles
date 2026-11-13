#!/usr/bin/env python3
"""Find video files that are incomplete or broken (e.g. abandoned torrents).

Usage: check-videos [-j JOBS] [--deep] [--bad-only] DIR_OR_FILE...

Checks per file, cheapest first:
  EMPTY       file is 0 bytes
  INCOMPLETE  sparse file: much less data on disk than its size (torrent
              clients pre-size files and fill them in as pieces arrive)
  INCOMPLETE  a 1 MiB block of pure zeros somewhere in the file (same thing on
              filesystems that don't support sparse files)
  BROKEN      ffprobe can't open it or finds no video stream (e.g. MP4 whose
              index/"moov atom" was never downloaded)
  TRUNCATED   decoding the last seconds fails (file cut off)
  CORRUPT     (--deep only) full decode reports errors; slow, reads everything
  OK          passed every check that ran

Needs ffprobe/ffmpeg on PATH. Read-only: never modifies files.
"""
import argparse
import os
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor

VIDEO_EXT = {
    ".mp4", ".m4v", ".mkv", ".webm", ".avi", ".mov", ".wmv", ".asf", ".flv",
    ".mpg", ".mpeg", ".m2ts", ".mts", ".ts", ".vob", ".3gp", ".ogv", ".divx", ".rmvb",
}
ZERO_BLOCK = 1 << 20  # 1 MiB of zeros = never real video data
SAMPLES = 32


def run(cmd, timeout):
    try:
        p = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
        return p.returncode, p.stdout, p.stderr
    except subprocess.TimeoutExpired:
        return -1, "", "timed out"


# ffmpeg noise that isn't damage: timestamp/keyframe/audio-header warnings
# common in AVI/MPG/WMV files that play fine.
BENIGN = (
    "non monotonically increasing dts", "non monotonous dts", "Timestamps are unset",
    "Last message repeated", "first frame is no keyframe", "Header missing", "unknown stream",
)


def real_errors(stderr):
    return [l for l in stderr.splitlines() if l.strip() and not any(b in l for b in BENIGN)]


def first_line(s):
    return next((l.strip() for l in s.splitlines() if l.strip()), "")[:120]


def check(path, deep):
    st = os.stat(path)
    size = st.st_size
    if size == 0:
        return "EMPTY", ""

    on_disk = getattr(st, "st_blocks", 0) * 512
    if on_disk and on_disk < size * 0.9:
        return "INCOMPLETE", f"only {on_disk / size:.0%} of the file has data (sparse)"

    if size > ZERO_BLOCK * 2:
        zero = bytes(ZERO_BLOCK)
        with open(path, "rb") as f:
            for i in range(SAMPLES):
                off = (size - ZERO_BLOCK) * i // (SAMPLES - 1)
                f.seek(off)
                if f.read(ZERO_BLOCK) == zero:
                    return "INCOMPLETE", f"zero-filled block at {off / size:.0%} of the file"

    rc, out, err = run(
        ["ffprobe", "-v", "error", "-select_streams", "v:0",
         "-show_entries", "format=duration:stream=codec_name", "-of", "default=nw=1", path],
        timeout=120,
    )
    if rc != 0:
        return "BROKEN", first_line(err) or "ffprobe failed"
    if "codec_name=" not in out:
        return "BROKEN", "no video stream"
    duration = next((l.split("=", 1)[1] for l in out.splitlines() if l.startswith("duration=")), "N/A")

    if duration not in ("N/A", ""):
        rc, _, err = run(
            ["ffmpeg", "-nostdin", "-v", "error", "-sseof", "-20", "-i", path,
             "-map", "0:v:0", "-t", "10", "-f", "null", "-"],
            timeout=300,
        )
        errs = real_errors(err)
        if rc != 0 or errs:
            return "TRUNCATED", (errs[0][:120] if errs else f"ffmpeg exit {rc}")

    if deep:
        rc, _, err = run(
            ["ffmpeg", "-nostdin", "-v", "error", "-i", path, "-map", "0:v:0", "-f", "null", "-"],
            timeout=6 * 3600,
        )
        errs = real_errors(err)
        if rc != 0 or errs:
            return "CORRUPT", f"{len(errs)} decode errors, first: {errs[0][:120] if errs else rc}"

    return "OK", ""


def files_in(paths):
    for p in paths:
        if os.path.isfile(p):
            yield p
            continue
        for root, dirs, files in os.walk(p):
            dirs.sort()
            for f in sorted(files):
                if os.path.splitext(f)[1].lower() in VIDEO_EXT:
                    yield os.path.join(root, f)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("paths", nargs="+")
    ap.add_argument("-j", "--jobs", type=int, default=2, help="parallel files (default 2; keep low on HDDs)")
    ap.add_argument("--deep", action="store_true", help="also fully decode each file (slow)")
    ap.add_argument("--bad-only", action="store_true", help="print only problem files, path only (for xargs)")
    a = ap.parse_args()

    files = list(files_in(a.paths))
    if not files:
        sys.exit("no video files found")
    counts = {}
    bad_size = 0

    def job(p):
        try:
            return p, *check(p, a.deep)
        except OSError as e:
            return p, "BROKEN", str(e)

    with ThreadPoolExecutor(a.jobs) as ex:
        for i, (p, status, why) in enumerate(ex.map(job, files), 1):
            counts[status] = counts.get(status, 0) + 1
            if status != "OK":
                bad_size += os.path.getsize(p) if os.path.exists(p) else 0
            if a.bad_only:
                if status != "OK":
                    print(p, flush=True)
            else:
                print(f"[{i}/{len(files)}] {status:<10} {p}" + (f"  ({why})" if why else ""), flush=True)

    if not a.bad_only:
        summary = ", ".join(f"{k}: {v}" for k, v in sorted(counts.items()))
        print(f"\n{len(files)} files — {summary}; problem files total {bad_size / 1e9:.1f} GB", file=sys.stderr)
    sys.exit(1 if any(k != "OK" for k in counts) else 0)


if __name__ == "__main__":
    main()
