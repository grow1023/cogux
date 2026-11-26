#!/usr/bin/env bash
# cogux_fixtures_gate.sh — HARD. macOS bash 3.2 safe, fail-closed.
set -u
ROOT="${1:-$(pwd)}"; case "$ROOT" in --*) ROOT="$(pwd)";; esac
RC=0
fail(){ RC=1; printf 'FAIL[%s]: %s\n' "cogux_fixtures" "$1" >&2; [ -n "${2:-}" ] && printf 'FIX[%s]: %s\n' "cogux_fixtures" "$2" >&2; return 0; }
F="$ROOT/fixtures"
[ -d "$F" ] || { fail "fixtures/ 없음" "대조되는 예시 프로젝트 두 개를 만든다"; exit 1; }
sec(){ awk -v h="$2" '/^## /{p=(index($0,h)>0)} p' "$1"; }
ids(){ sec "$1" "$2" | grep -o '^| `[a-z0-9-]*`' | sed 's/^| `//;s/`$//' | sort -u; }
cnt=0; TMP="${TMPDIR:-/tmp}/cogux_gate_$$"; mkdir -p "$TMP"
for d in "$F"/*/; do
  [ -f "$d/COGUX.md" ] || continue
  cnt=$((cnt+1)); c="$d/COGUX.md"; nm="$(basename "$d")"
  [ -f "$d/README.md" ] && [ -f "$d/index.html" ] && [ -f "$d/index.before.html" ] || fail "$nm: README.md, index.html, index.before.html 중 없는 것이 있다" "$d 에 세 파일을 둔다"
  cmp -s "$d/index.html" "$d/index.before.html" && fail "$nm: 화면 코드가 수정되지 않았다 (전후 동일)" "$d/index.html 에 설계 결정을 구현한다"
  for h in '1. 프로젝트 읽기' '2. 선택한 원칙' '3. 제외한 원칙' '4. 설계 결정' '6. 검증 결과' '7. 미확인'; do
    grep -q "^## $h" "$c" || fail "$nm: '$h' 절이 없다" "$c 에 '## $h' 절을 쓴다"
  done
  rd="$(sec "$c" '1. 프로젝트 읽기' | grep -c '^| [UTSC][0-9]')"
  [ "$rd" -ge 3 ] || fail "$nm: 프로젝트 읽기 항목이 3개 미만 ($rd)" "$c 1절에 번호가 붙은 항목을 채운다"
  sec "$c" '1. 프로젝트 읽기' | grep '^| [UTSC][0-9]' | awk -F'|' '{g=$(NF-1); gsub(/^ +| +$/,"",g); if(length(g)<2) bad=1} END{exit bad}' || fail "$nm: 근거 칸이 빈 항목이 있다" "근거에 파일 경로나 진술을 쓰거나 (assumed)라고 쓴다"
  sel="$(ids "$c" '2. 선택한 원칙')"; exc="$(ids "$c" '3. 제외한 원칙')"; dec="$(ids "$c" '4. 설계 결정')"
  [ -n "$sel" ] || fail "$nm: 선택한 원칙이 없다" "2절 표를 채운다"
  [ -n "$exc" ] || fail "$nm: 제외한 원칙이 없다" "3절에 제외한 원칙과 이유를 쓴다"
  for i in $sel $exc; do [ -f "$ROOT/references/$i.md" ] || fail "$nm: 원칙 $i 이(가) references/ 에 없다" "references/$i.md 를 만들거나 id 를 고친다"; done
  for i in $dec; do printf '%s\n' "$sel" | grep -qx "$i" || fail "$nm: 설계 결정의 원칙 $i 이(가) 선택 목록에 없다" "2절에 $i 를 추가하거나 결정을 지운다"; done
  for i in $sel; do printf '%s\n' "$dec" | grep -qx "$i" || fail "$nm: 선택한 원칙 $i 에 설계 결정이 없다" "4절에 $i 의 결정 행을 쓴다"; done
  for i in $sel; do printf '%s\n' "$exc" | grep -qx "$i" && fail "$nm: $i 가 선택과 제외에 모두 있다" "한쪽에서 지운다"; done
  sec "$c" '2. 선택한 원칙' | grep '^| `' | awk -F'|' '{r=$3; y=$4; gsub(/^ +| +$/,"",r); gsub(/^ +| +$/,"",y); if(r !~ /[UTSC][0-9]/ || length(y)<15) bad=1} END{exit bad}' || fail "$nm: 선택 이유가 짧거나 프로젝트 읽기 번호가 없다" "각 행에 근거 번호(예: U1)와 15자 이상 이유를 쓴다"
  v="$(sec "$c" '6. 검증 결과' | grep -c '통과\|실패\|미확인')"
  [ "$v" -ge 1 ] || fail "$nm: 검증 결과에 통과·실패·미확인 표기가 없다" "6절에 결과를 쓴다"
  printf '%s\n' "$sel" > "$TMP/set_$cnt"
done
[ "$cnt" -ge 2 ] || fail "COGUX.md 가 있는 예시 프로젝트가 2개 미만 ($cnt)" "대조되는 두 번째 프로젝트를 만든다"
if [ "$cnt" -ge 2 ]; then
  [ -n "$(comm -23 "$TMP/set_1" "$TMP/set_2")" ] && [ -n "$(comm -13 "$TMP/set_1" "$TMP/set_2")" ] || fail "두 예시 프로젝트의 선택 원칙이 서로 다르지 않다" "프로젝트 읽기에 맞게 선택을 다시 한다"
fi
rm -rf "$TMP"
T="$HOME/.claude/qa-canon/theme_motion_gate.sh"
if [ -f "$T" ]; then bash "$T" "$F" >/dev/null 2>&1 || fail "fixtures 의 theme_motion_gate 실패" "bash $T $F 를 실행해 출력을 읽는다"; else fail "theme_motion_gate.sh 가 없다 ($T)" "~/.claude/qa-canon 을 확인한다"; fi
[ "$RC" -eq 0 ] && echo "PASS[cogux_fixtures]: 예시 프로젝트 $cnt 개의 기록, 원칙 차이, 테마 게이트 확인"
exit "$RC"
