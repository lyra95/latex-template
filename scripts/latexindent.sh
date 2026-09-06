#!/bin/sh
# 컨테이너 안에서 LaTeX Workshop 의 포매터(latexindent)를 대신 실행한다.
#   sh scripts/latexindent.sh <WORKSPACE_FOLDER(호스트)> <TMPFILE(호스트)> [latexindent 추가 인자...]
#
# LaTeX Workshop 은 포매팅할 내용을 문서와 같은 디렉터리에 __latexindent_temp_<파일명> 으로 써 두고,
# latexindent 의 stdout 을 결과로 받아 문서를 교체한다. 그런데 %TMPFILE% 은 호스트 경로이므로
# 프로젝트가 /work 에 마운트된 컨테이너 안 경로로 바꿔 준다:
#   d:/dev/latex-template/chapters/__latexindent_temp_ch1.tex  ->  /work/chapters/__latexindent_temp_ch1.tex
# 앞부분을 "길이" 로 잘라내므로 드라이브 문자의 대소문자가 달라도 상관없다.
set -eu

HOST_WS="${1:?usage: latexindent.sh <workspace-folder> <tmpfile> [args...]}"
TMPFILE="${2:?usage: latexindent.sh <workspace-folder> <tmpfile> [args...]}"
shift 2

HOST_WS="${HOST_WS%/}"
REL=$(printf '%s\n%s\n' "$HOST_WS" "$TMPFILE" | awk 'NR==1{n=length($0)} NR==2{print substr($0,n+1)}')
case "$REL" in
    /*) ;;
    *)  REL="/$REL" ;;
esac
FILE="/work$REL"

# -c: indent.log / 백업 파일 위치. 문서 디렉터리에 두면 LaTeX Workshop 이 포매팅 후 indent.log 를 지워 준다.
# 나머지 인자(-y=defaultIndent: '...' 등)는 LaTeX Workshop 이 넘겨준 그대로 전달한다.
exec latexindent -c "$(dirname "$FILE")/" "$@" "$FILE"
