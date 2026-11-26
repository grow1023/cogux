#!/usr/bin/env bash
# count_gate — HARD. "있어야 할 것이 실제로 몇 개인가"를 센다 — '조용히 빈손인 조회' 차단.
# Why: 지배적 결함 패턴 — 이름 규칙이 실제와 어긋나 0건을 찾고, 0은 오류가 아니라서 통과한다
#      (같은 모양의 누락이 로그에는 정상으로 보이므로 세어 봐야 드러난다).
# 계약: gates/expected_counts.tsv 각 행 "<min><TAB><root 상대 glob>" 에 대해 매치 파일 수 >= min.
#   tsv 없음/유효 행 0개 = FAIL (측정 없는 통과 금지). '#' 주석 허용.
#   주의: bash 3.2 라 '**' 재귀 glob 없음 — 깊은 경로는 명시적으로 (예: out/*/*.png).
# macOS bash 3.2 safe, fail-closed.
set -u
ROOT="${1:-$(pwd)}"; case "$ROOT" in --*) ROOT="$(pwd)";; esac
G="$(cd "$(dirname "$0")" && pwd)"
TSV="$G/expected_counts.tsv"
RC=0
fail(){ RC=1; printf 'FAIL[count]: %s\n' "$1" >&2; [ -n "${2:-}" ] && printf 'FIX[count]: %s\n' "$2" >&2; return 0; }   # fail <reason> [fix]

[ -f "$TSV" ] || { fail "expected_counts.tsv 없음 — 셀 것을 정의하라 (빈손 계약 금지)" "$TSV 를 만들고 '<최소개수><TAB><root 상대 glob>' 행을 쓴다. 예: printf '1\\tREADME.md\\n' > \"$TSV\""; exit 1; }

rows=0
while IFS=$'\t' read -r min glob || [ -n "${min:-}" ]; do
  case "${min:-}" in ''|'#'*) continue;; esac
  case "$min" in *[!0-9]*) fail "형식 오류: min이 숫자가 아님 ('$min')" "$TSV 의 해당 행을 '<숫자><TAB><glob>' 형식으로 고친다"; continue;; esac
  [ -n "${glob:-}" ] || { fail "형식 오류: glob 없음 (min=$min)" "$TSV 의 해당 행에 TAB 뒤 glob 을 넣는다"; continue; }
  rows=$((rows+1))
  n=$(cd "$ROOT" 2>/dev/null && {
        shopt -s nullglob 2>/dev/null || true
        set -- $glob
        c=0; for f in "$@"; do [ -e "$f" ] && c=$((c+1)); done; echo "$c"
      })
  [ "${n:-0}" -ge "$min" ] || fail "'$glob' 실측 ${n:-0}개 < 기대 최소 $min — 조용한 빈손 의심" "(cd \"$ROOT\" && ls -d $glob) 로 실제 경로를 확인한다. 이름 규칙이 어긋났으면 산출물을 만드는 코드를 고친다"
done < "$TSV"

[ "$rows" -ge 1 ] || fail "유효 카운트 행 0개 — 셀 것이 없다" "$TSV 에 주석이 아닌 '<최소개수><TAB><glob>' 행을 1개 이상 둔다"
[ "$RC" -eq 0 ] && printf 'PASS[count]: %d개 카운트 계약 전수 충족\n' "$rows"
exit "$RC"
