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
        -e "s,https?://(archive|security)\\.ubuntu\\.com/ubuntu,${MIRROR},g" \
        -e "s,https?://ports\\.ubuntu\\.com/ubuntu-ports,${MIRROR},g" \
        /etc/apt/sources.list.d/ubuntu.sources && \
    grep -qF "$MIRROR" /etc/apt/sources.list.d/ubuntu.sources

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    make \
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
    && rm -rf /var/lib/apt/lists/* \
    && apt autoremove --purge -y

RUN curl -fsSL https://claude.ai/install.sh | bash && \
    rm -rf /tmp/* /root/.cache

ENV PATH="${PATH}:/root/.local/bin"
