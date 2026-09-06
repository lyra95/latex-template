#!/bin/sh
# 컨테이너 안에서 실행되는 빌드 진입점.
#   sh scripts/latexmk.sh [root.tex]      (기본값: main.tex)
#
# latexmk(xelatex, synctex 켬)로 빌드한 뒤, synctex 파일 안의 컨테이너 경로(/work/...)를
# 호스트 경로(HOST_DIR)로 바꿔 놓는다. 그래야 호스트에서 돌아가는 pdf 뷰어(sioyek)가
# forward/inverse search 때 .tex 파일을 찾을 수 있다. (scripts/fix-synctex.sh 참고)
#
# 환경변수
#   HOST_DIR  /work 가 마운트된 호스트 쪽 절대경로. 호스트 launcher가 넘겨준다.
#             비어 있으면 synctex 경로 치환은 건너뛴다(컨테이너 밖에서 그냥 latexmk로 쓸 때).
#   OUTDIR    출력 디렉터리 (기본값: out). .vscode/settings.json 의 latex-workshop.latex.outDir 와 맞출 것.
set -u

ROOT="${1:-main.tex}"
OUTDIR="${OUTDIR:-out}"
HERE="$(dirname "$0")"

latexmk -xelatex -synctex=1 -interaction=nonstopmode -file-line-error \
    -outdir="$OUTDIR" "$ROOT"
STATUS=$?

# latexmk가 에러를 내도(nonstopmode) pdf/synctex는 갱신되었을 수 있으므로 치환은 항상 시도한다.
BASE="$(basename "${ROOT%.tex}")"
sh "$HERE/fix-synctex.sh" "$OUTDIR/$BASE.synctex.gz"

exit $STATUS
