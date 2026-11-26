#!/usr/bin/env python3
"""時間切れで止めるための実行役。`run_with_timeout.py <秒> <コマンド...>`

コマンドを新しいプロセスグループで動かし、時間を超えたらグループごと止めて、
わかりやすい文を出して 124 で終わる（xcodebuild が固まったときに、長く待たないため）。
"""

import os
import signal
import subprocess
import sys


def main() -> int:
    seconds = int(sys.argv[1])
    process = subprocess.Popen(sys.argv[2:], start_new_session=True)
    try:
        return process.wait(timeout=seconds)
    except subprocess.TimeoutExpired:
        sys.stderr.write(f"時間切れ: {seconds} 秒たっても終わらないので止めました。\n")
        for sig in (signal.SIGTERM, signal.SIGKILL):
            try:
                os.killpg(process.pid, sig)
            except ProcessLookupError:
                break
            try:
                process.wait(timeout=10)
                break
            except subprocess.TimeoutExpired:
                continue
        return 124
    except KeyboardInterrupt:
        os.killpg(process.pid, signal.SIGTERM)
        return 130


if __name__ == "__main__":
    sys.exit(main())
