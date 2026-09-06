#!/bin/sh
# .synctex.gz 안의 "Input:" 경로를 컨테이너 경로에서 호스트 경로로 치환한다.
#   sh scripts/fix-synctex.sh out/main.synctex.gz
#
# 예)  Input:62:/work/./chapters/ch1.tex  ->  Input:62:D:/dev/latex-template/chapters/ch1.tex
#
# - 중간의 "./" 도 함께 지운다. synctex 파서는 경로 앞의 ./ 만 무시하기 때문에
#   /work/./chapters/ch1.tex 는 뷰어가 넘겨준 .../chapters/ch1.tex 와 매치되지 않는다.
# - 호스트 경로의 역슬래시는 슬래시로 바꾼다. Windows 빌드의 synctex 파서는 / 와 \ 를,
#   그리고 대소문자를 구분하지 않고 비교하므로 슬래시로 통일해도 안전하다.
#
# 환경변수
#   HOST_DIR       치환할 호스트 경로 (필수. 없으면 아무 것도 하지 않음)
#   CONTAINER_DIR  치환될 컨테이너 경로 (기본값: /work)
set -eu

SYNCTEX="${1:?usage: fix-synctex.sh <file.synctex.gz>}"
CONTAINER_DIR="${CONTAINER_DIR:-/work}"
HOST_DIR="${HOST_DIR:-}"

[ -n "$HOST_DIR" ] || exit 0
[ -f "$SYNCTEX" ] || exit 0

# 역슬래시 -> 슬래시, 끝의 슬래시 제거
HOST_DIR=$(printf '%s' "$HOST_DIR" | sed 's,\\,/,g; s,/*$,,')
CONTAINER_DIR=$(printf '%s' "$CONTAINER_DIR" | sed 's,/*$,,')

# sed 패턴/치환문에 쓰기 위한 이스케이프 (구분자 | 포함)
pat=$(printf '%s' "$CONTAINER_DIR" | sed 's/[][\.*^$|]/\\&/g')
rep=$(printf '%s' "$HOST_DIR" | sed 's/[&|\\]/\\&/g')

TMP="$SYNCTEX.tmp"
gzip -dc "$SYNCTEX" \
    | sed -e "s|^\(Input:[0-9]*:\)$pat/\(\./\)*|\1$rep/|" \
    | gzip -c > "$TMP"
mv "$TMP" "$SYNCTEX"
