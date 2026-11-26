#!/usr/bin/env bash
# cogux_skill_gate.sh — HARD. macOS bash 3.2 safe, fail-closed.
set -u
ROOT="${1:-$(pwd)}"; case "$ROOT" in --*) ROOT="$(pwd)";; esac
RC=0
fail(){ RC=1; printf 'FAIL[%s]: %s\n' "cogux_skill" "$1" >&2; [ -n "${2:-}" ] && printf 'FIX[%s]: %s\n' "cogux_skill" "$2" >&2; return 0; }
S="$ROOT/SKILL.md"
[ -f "$S" ] || { fail "SKILL.md 없음" "$ROOT/SKILL.md 를 만든다"; exit 1; }
fm="$(awk 'NR==1&&$0!="---"{exit} NR>1&&$0=="---"{exit} NR>1{print}' "$S")"
printf '%s\n' "$fm" | grep -q '^name: cogux$' || fail "frontmatter name 이 cogux 가 아니다" "SKILL.md 첫 줄 아래에 'name: cogux' 를 쓴다"
desc="$(printf '%s\n' "$fm" | grep '^description:' || true)"
[ -n "$desc" ] || fail "frontmatter description 없음" "description: 줄을 추가한다"
printf '%s' "$desc" | python3 -c 'import sys;sys.exit(0 if any(0xAC00<=ord(c)<=0xD7A3 for c in sys.stdin.read()) else 1)' || fail "description 에 한국어 트리거 없음" "description 에 한국어 트리거 단어를 넣는다"
printf '%s' "$desc" | grep -qiE 'cognitive|ux psychology|laws of ux' || fail "description 에 영어 트리거 없음" "description 에 cognitive, UX psychology, laws of UX 중 하나를 넣는다"
for h in '### 1. 프로젝트 읽기' '### 2. 원칙 선택' '### 3. 설계 결정' '### 4. 구현' '### 5. 검증' '### 6. 기록 파일'; do
  grep -qF "$h" "$S" || fail "SKILL.md 에 '$h' 단계 없음" "SKILL.md 에 '$h' 제목과 내용을 쓴다"
done
grep -q '제외한 원칙' "$S" || fail "제외한 원칙 목록 규정이 없다" "2단계에 제외한 원칙 목록 규칙을 쓴다"
grep -q '(assumed)' "$S" || fail "(assumed) 표시 규정이 없다" "1단계에 근거 없는 항목은 (assumed)로 표시한다고 쓴다"
grep -q 'uiux-integrated-workflow.md' "$S" || fail "통합 워크플로우 링크 없음" "경계 절에 ~/.claude/rules/uiux-integrated-workflow.md 를 적는다"
for k in no_vertical_stripe_gate.sh theme_motion_gate.sh korean-line-wrapping.md; do grep -q "$k" "$S" || fail "필수 게이트 $k 언급 없음" "4단계에 $k 실행을 쓴다"; done
if grep -qE '[0-9]+ ?(laws|biases|가지 원칙|개 원칙|개의 원칙)' "$S" "$ROOT/references/INDEX.md" 2>/dev/null; then fail "원칙 개수를 하드코딩한 문구가 있다" "개수 문구를 지우고 파일 수를 직접 세도록 쓴다"; fi
[ "$RC" -eq 0 ] && echo "PASS[cogux_skill]: SKILL.md 구조 확인"
exit "$RC"
