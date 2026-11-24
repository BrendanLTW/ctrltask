#!/usr/bin/env bash
# PLAN 4.3: time to first frame with 2,000 tasks, in profile mode
# (docs/performance.md). Usage: tool/measure_startup.sh <device-id> [runs]
set -euo pipefail
device="${1:?usage: tool/measure_startup.sh <device-id> [runs]}"
runs="${2:-3}"
# The first launch seeds the perf database; it isn't timed.
flutter run --profile --dart-define=PERF=true -d "$device" --trace-startup >/dev/null
times=()
for i in $(seq "$runs"); do
  flutter run --profile --dart-define=PERF=true -d "$device" --trace-startup >/dev/null
  ms=$(python3 -c "import json;print(round(json.load(open('build/start_up_info.json'))['timeToFirstFrameMicros']/1000))")
  echo "run $i: ${ms} ms to first frame"
  times+=("$ms")
done
printf '%s\n' "${times[@]}" | sort -n | awk '{a[NR]=$1} END {print "median: " a[int((NR+1)/2)] " ms (target < 1500)"}'
