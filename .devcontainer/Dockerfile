FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN sed -i 's|http://archive.ubuntu.com/ubuntu|http://mirror.kakao.com/ubuntu|g' /etc/apt/sources.list && \
    sed -i 's|http://security.ubuntu.com/ubuntu|http://mirror.kakao.com/ubuntu|g' /etc/apt/sources.list && \
    apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    make \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    texlive-full \
    texlive-lang-korean \
    texlive-xetex \
    texlive-luatex \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    ko.tex \
    fonts-noto-cjk \
    fonts-nanum \
    fonts-naver-d2coding \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    pandoc \
    && rm -rf /var/lib/apt/lists/*

RUN fc-cache -fv

WORKDIR /workspace

SHELL ["/bin/bash", "-c"]
