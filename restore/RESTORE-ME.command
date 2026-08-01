#!/bin/sh
# ============================================================
#  ColdArchive — RESTORE-ME
#
#  이 폴더에 보관된 파일을 원래 자리로 되돌립니다.
#  Puts the files kept in this folder back where they came from.
#
#  ColdArchive 앱이 없어도, 인터넷이 없어도, 다른 맥에서도 동작합니다.
#  하는 일은 mv 뿐입니다. 아래 코드를 그대로 읽어 보세요.
#
#  사용법 / Usage
#    더블클릭 / double-click        확인을 받고 복원
#    sh RESTORE-ME.command --list      복원 대상만 보기
#    sh RESTORE-ME.command --dry-run   옮기지 않고 계획만
#    sh RESTORE-ME.command --yes       확인 없이 복원
#
#  실행 권한이 없다고 하면 (동기화 과정에서 사라질 수 있습니다):
#    sh "이 파일의 경로"
# ============================================================
#
# 이 스크립트는 배열도 bash 확장도 쓰지 않는 순수 POSIX sh 입니다.
# 어떤 셸에서도, 오래된 시스템에서도 돌아야 하기 때문입니다.

set -u

MODE=interactive
case "${1:-}" in
  --list)    MODE=list ;;
  --dry-run) MODE=dry ;;
  --yes|-y)  MODE=yes ;;
  "")        ;;
  *) printf '알 수 없는 옵션 / unknown option: %s\n' "$1"; exit 2 ;;
esac

# 스크립트가 놓인 폴더 = 아카이브 루트. 폴더째 옮겨도 그대로 동작한다.
HERE=$(cd -- "$(dirname -- "$0")" && pwd -P) || exit 1
MANIFEST="$HERE/coldarchive-manifest.tsv"

say() { printf '%s\n' "$*"; }
hr()  { printf '%s\n' "------------------------------------------------------------"; }
pause_if_tty() { if [ -t 0 ]; then say ""; printf '닫으려면 Enter / press Enter to close '; read -r _dummy; fi; }

say ""
say "ColdArchive — 복원 / Restore"
say "보관함 / archive folder:"
say "  $HERE"
hr

if [ ! -f "$MANIFEST" ]; then
  say "매니페스트를 찾을 수 없습니다 / manifest not found:"
  say "  $MANIFEST"
  say "이 스크립트는 보관함 안에 그대로 두고 실행해야 합니다."
  pause_if_tty
  exit 1
fi

# '원래 위치' 를 지금 이 사용자의 실제 경로로 편다.
# ~ 로 적혀 있으므로 다른 맥·다른 계정에서도 맞는 자리로 돌아간다.
expand_dest() {
  case "$1" in
    "~/"*) printf '%s\n' "$HOME/${1#\~/}" ;;
    "~")   printf '%s\n' "$HOME" ;;
    *)     printf '%s\n' "$1" ;;
  esac
}

# 이 심링크가 정말 이 아카이브를 가리키는가.
# (사용자가 직접 만든 다른 심링크는 절대 건드리지 않는다)
points_here() {
  _t=$(readlink "$1" 2>/dev/null) || return 1
  [ "${_t#"$HERE"/}" != "$_t" ]
}

# 한 항목이 지금 복원 가능한 상태인지 판정한다.
#   ready / missing(아카이브에 없음) / occupied(원래 자리에 실제 파일) / foreign(남의 링크) / blocked(권한)
classify() {
  [ -e "$2" ] || { printf 'missing\n'; return; }
  if [ -L "$1" ]; then
    points_here "$1" || { printf 'foreign\n'; return; }
  elif [ -e "$1" ]; then
    printf 'occupied\n'; return
  fi
  _p=$(dirname -- "$1")
  [ -d "$_p" ] || { printf 'ready\n'; return; }   # 없는 폴더는 복원 때 만든다
  [ -w "$_p" ] || { printf 'blocked\n'; return; }
  printf 'ready\n'
}

# ---------- 1차: 훑어보기 ----------
total=0; ready=0; missing=0; occupied=0; foreign=0; blocked=0
while IFS='	' read -r orig rel _bytes || [ -n "${orig:-}" ]; do
  case "${orig:-}" in ''|'#'*) continue ;; esac
  [ -n "${rel:-}" ] || continue
  total=$((total + 1))
  dest=$(expand_dest "$orig")
  case $(classify "$dest" "$HERE/$rel") in
    ready)    ready=$((ready + 1)) ;;
    missing)  missing=$((missing + 1)) ;;
    occupied) occupied=$((occupied + 1)) ;;
    foreign)  foreign=$((foreign + 1)) ;;
    blocked)  blocked=$((blocked + 1)) ;;
  esac
done < "$MANIFEST"

say "기록된 항목 / entries       : $total"
say "복원 가능   / restorable    : $ready"
[ "$missing"  -gt 0 ] && say "보관함에 없음 / missing   : $missing"
[ "$occupied" -gt 0 ] && say "이미 파일 있음  / occupied  : $occupied  (덮어쓰지 않습니다)"
[ "$foreign"  -gt 0 ] && say "우리 링크 아님  / foreign   : $foreign  (건드리지 않습니다)"
[ "$blocked"  -gt 0 ] && say "권한 없음    / not writable : $blocked"
hr

# ---------- 목록·모의 실행 ----------
if [ "$MODE" = list ] || [ "$MODE" = dry ]; then
  while IFS='	' read -r orig rel _bytes || [ -n "${orig:-}" ]; do
    case "${orig:-}" in ''|'#'*) continue ;; esac
    [ -n "${rel:-}" ] || continue
    dest=$(expand_dest "$orig")
    state=$(classify "$dest" "$HERE/$rel")
    printf '  [%s] %s\n' "$state" "$rel"
    printf '        -> %s\n' "$dest"
  done < "$MANIFEST"
  hr
  say "계획만 출력했습니다. 실제로 복원하려면 옵션 없이 실행하세요."
  exit 0
fi

if [ "$ready" -eq 0 ]; then
  say "복원할 항목이 없습니다 / nothing to restore."
  pause_if_tty
  exit 0
fi

# ---------- 확인 ----------
if [ "$MODE" = interactive ]; then
  if [ ! -t 0 ]; then
    say "확인을 받을 수 없어 중단합니다. --yes 를 붙여 실행하세요."
    exit 1
  fi
  say "$ready 개 파일을 원래 자리로 되돌립니다."
  say "클라우드에만 있는 파일은 다시 내려받으므로 시간이 걸릴 수 있습니다."
  say ""
  printf '진행할까요? / proceed? [y/N] '
  read -r answer
  case "$answer" in
    y|Y|yes|YES) ;;
    *) say "취소했습니다 / cancelled."; exit 0 ;;
  esac
  hr
fi

# ---------- 2차: 실제 복원 ----------
ok=0; fail=0
while IFS='	' read -r orig rel _bytes || [ -n "${orig:-}" ]; do
  case "${orig:-}" in ''|'#'*) continue ;; esac
  [ -n "${rel:-}" ] || continue
  dest=$(expand_dest "$orig")
  src="$HERE/$rel"
  [ "$(classify "$dest" "$src")" = ready ] || continue

  # 여기서 다시 확인한다 — 1차 판정 이후 상황이 바뀌었을 수 있다
  if [ -L "$dest" ]; then
    points_here "$dest" || { printf '  건너뜀(우리 링크 아님) %s\n' "$dest"; continue; }
    rm -f -- "$dest" || { printf '  실패(링크 삭제) %s\n' "$dest"; fail=$((fail + 1)); continue; }
  elif [ -e "$dest" ]; then
    printf '  건너뜀(이미 파일 있음) %s\n' "$dest"; continue
  fi

  mkdir -p -- "$(dirname -- "$dest")" 2>/dev/null
  if mv -- "$src" "$dest" 2>/dev/null; then
    printf '  OK   %s\n' "$dest"
    ok=$((ok + 1))
  else
    printf '  실패 %s\n' "$dest"
    # 옮기지 못했으면 링크라도 되살려 원래 상태로 둔다
    [ -e "$src" ] && [ ! -e "$dest" ] && ln -s -- "$src" "$dest" 2>/dev/null
    fail=$((fail + 1))
  fi
done < "$MANIFEST"

hr
say "복원 완료 / restored : $ok"
[ "$fail" -gt 0 ] && say "실패     / failed    : $fail"
say ""
say "보관함에 빈 폴더가 남았다면 지워도 됩니다."
pause_if_tty
exit 0

