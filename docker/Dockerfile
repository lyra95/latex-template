# LaTeX 빌드용 이미지. 호스트에는 TeX를 설치하지 않고, 이 이미지 안에서 latexmk를 돌린다.
#
#   docker build -t latex-template docker
#   (또는 VS Code: Terminal > Run Task > "latex: build docker image")
FROM ubuntu:26.04

ARG DEBIAN_FRONTEND=noninteractive

# amd64는 archive/security.ubuntu.com, arm64는 ports.ubuntu.com/ubuntu-ports를 사용한다.
# 카카오 미러에는 ubuntu-ports가 없으므로 arm64에서는 KAIST 미러를 쓴다.
RUN ARCH="$(dpkg --print-architecture)"; \
    case "$ARCH" in \
        amd64|i386) MIRROR="http://mirror.kakao.com/ubuntu" ;; \
        *)          MIRROR="http://ftp.kaist.ac.kr/ubuntu-ports" ;; \
    esac; \
    sed -i -E \
        -e "s,https?://(archive|security)\.ubuntu\.com/ubuntu,${MIRROR},g" \
        -e "s,https?://ports\.ubuntu\.com/ubuntu-ports,${MIRROR},g" \
        /etc/apt/sources.list.d/ubuntu.sources && \
    grep -qF "$MIRROR" /etc/apt/sources.list.d/ubuntu.sources

# texlive-full 에 latexmk, synctex, latexindent(texlive-extra-utils)가 모두 들어 있다.
RUN apt-get update && apt-get install -y --no-install-recommends \
    texlive-full \
    texlive-lang-korean \
    texlive-xetex \
    texlive-luatex \
    ko.tex \
    fonts-noto-cjk \
    fonts-nanum \
    fonts-naver-d2coding \
    pandoc \
    && fc-cache -fv \
    && rm -rf /var/lib/apt/lists/*

# 프로젝트는 이 경로에 마운트된다 (scripts/fix-synctex.sh 의 CONTAINER_DIR 기본값과 같아야 한다).
WORKDIR /work
