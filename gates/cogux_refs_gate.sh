#!/usr/bin/env bash
# cogux_refs_gate.sh — HARD. macOS bash 3.2 safe, fail-closed.
set -u
ROOT="${1:-$(pwd)}"; case "$ROOT" in --*) ROOT="$(pwd)";; esac
RC=0
fail(){ RC=1; printf 'FAIL[%s]: %s\n' "cogux_refs" "$1" >&2; [ -n "${2:-}" ] && printf 'FIX[%s]: %s\n' "cogux_refs" "$2" >&2; return 0; }
D="$ROOT/references"
[ -d "$D" ] || { fail "references/ 없음" "references/ 에 원칙마다 파일을 만든다"; exit 1; }
n=0
for f in "$D"/*.md; do
  [ -e "$f" ] || continue
  b="$(basename "$f")"; [ "$b" = "INDEX.md" ] && continue
  n=$((n+1))
  for k in 'id' '분류' '정의' '출처' '읽은 범위' '적용할 때' '적용하지 않을 때' '관찰 확인'; do
    v="$(grep -m1 "^- \*\*$k:\*\*" "$f" | sed "s/^- \*\*$k:\*\* *//")"
    [ -n "$v" ] || fail "$b: '$k' 필드가 없거나 비어 있다" "$f 에 '- **$k:** 내용' 줄을 채운다"
  done
  grep -q '^# ' "$f" || fail "$b: 이름 제목(# ...)이 없다" "$f 첫 줄에 '# 이름'을 쓴다"
  idv="$(grep -m1 '^- \*\*id:\*\*' "$f" | sed 's/^- \*\*id:\*\* *//')"
  [ "$idv" = "${b%.md}" ] || fail "$b: id($idv)가 파일 이름과 다르다" "id 를 ${b%.md} 로 맞춘다"
  u="$(grep -m1 '^- \*\*출처:\*\*' "$f" | sed 's/^- \*\*출처:\*\* *//')"
  case "$u" in https://*) ;; *) fail "$b: 출처가 https URL 이 아니다 ('$u')" "$f 의 출처를 실제 https 주소로 고친다";; esac
  grep -q "\`${b%.md}\`" "$D/INDEX.md" || fail "$b: INDEX.md 에 없다" "INDEX.md 표에 행을 추가한다"
done
[ "$n" -ge 1 ] || fail "원칙 파일 0개" "references/ 에 원칙 파일을 만든다"
[ "$RC" -eq 0 ] && echo "PASS[cogux_refs]: 원칙 파일 $n 개의 필드와 출처 확인"
exit "$RC"
