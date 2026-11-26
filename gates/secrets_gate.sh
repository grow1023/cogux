#!/usr/bin/env bash
# secrets_gate — HARD. R4. 추적 + 미추적(비무시) 파일에서 키 패턴 0건. 이름 기준 디렉토리 제외 없음 (git 의 무시 규칙만 신뢰).
# 2026-09-25 F-07: OpenAI proj/svcacct, Anthropic, LiveKit secret 할당, GitHub/AWS/Slack/Google 패턴.
set -u
ROOT="${1:-$(pwd)}"; case "$ROOT" in --*) ROOT="$(pwd)";; esac
PAT='(sk-(proj-|ant-api[0-9]{2}-|ant-|svcacct-)?[A-Za-z0-9_-]*[A-Za-z0-9_]{24}|AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----|ghp_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{30,}|xox[baprs]-[A-Za-z0-9-]{10,}|AIza[0-9A-Za-z_-]{30,}|(LIVEKIT_API_SECRET|SUPABASE_SERVICE_ROLE_KEY|ANTHROPIC_API_KEY|OPENAI_API_KEY|TYPESAFE_API_KEY)[[:space:]]*[:=][[:space:]]*["'"'"']?[A-Za-z0-9_./+-]{16,})'
# cogux: 홈 리포의 info/exclude(*)가 새 파일을 전부 가려서 git 목록 대신 find 를 쓴다.
LIST="$(cd "$ROOT" && find . -type f -not -path './.git/*' | sed 's|^\./||' | grep -vE '(^|/)(fixtures|__fixtures__)/' | grep -vE '\.(png|jpg|jpeg|gif|webp|mp3|mp4|mov|wav|lock|woff2?|ttf|otf)$' || true)"
[ -n "$LIST" ] || { printf 'FAIL[secrets]: 스캔 대상 파일 0개\n' >&2; printf 'FIX[secrets]: git -C "%s" ls-files -co --exclude-standard 로 파일이 보이는지 확인한다 (.gitignore 가 전부 가리는지 점검)\n' "$ROOT" >&2; exit 1; }
HITS="$(cd "$ROOT" && printf '%s\n' "$LIST" | tr '\n' '\0' | xargs -0 grep -IlE "$PAT" 2>&1)"; GREP_RC=$?
if [ "$GREP_RC" -gt 1 ]; then printf 'FAIL[secrets]: grep 오류 (exit %s) — 스캔 미완료\n%s\n' "$GREP_RC" "$HITS" >&2; printf 'FIX[secrets]: 위 grep 오류가 가리키는 파일(권한·깨진 링크)을 고친 뒤 다시 실행한다\n' >&2; exit 1; fi
if [ -n "$HITS" ]; then printf 'FAIL[secrets]: secret-like pattern found in:\n%s\n' "$HITS" >&2; printf 'FIX[secrets]: 위 파일에서 값을 지우고 환경 변수로 옮긴다. 이미 커밋된 키는 발급처에서 폐기하고 새로 발급한다\n' >&2; exit 1; fi
printf 'PASS[secrets]: %s files scanned (tracked+untracked, gitignore respected), no key patterns\n' "$(printf '%s\n' "$LIST" | wc -l | tr -d ' ')"
exit 0
