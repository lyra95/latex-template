# CLI에서 쓰는 편의 타깃. VS Code 안에서는 LaTeX Workshop이 같은 컨테이너 명령을 직접 실행한다
# (.vscode/settings.json 의 latex-workshop.latex.tools 참고).
#
#   make image   # 이미지 빌드 (최초 1회)
#   make pdf     # out/main.pdf 생성 (+ synctex 경로 치환)
#   make format  # latexindent 로 *.tex 정리
#   make html    # pandoc 으로 html/index.html 생성
IMAGE ?= latex-template
ROOT  ?= main.tex

RUN = docker run --rm -v "$(CURDIR):/work" -w /work -e "HOST_DIR=$(CURDIR)" $(IMAGE)

.PHONY: all image pdf html format clean

all: pdf html

image:
	docker build -t $(IMAGE) docker

pdf:
	$(RUN) sh scripts/latexmk.sh $(ROOT)

html:
	$(RUN) sh -c 'mkdir -p html && pandoc $(ROOT) -s -o html/index.html \
		--katex="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/" \
		--toc \
		--metadata title="LaTeX Template with Korean Support"'
	@echo "HTML generated: html/index.html"

format:
	$(RUN) latexindent -w -s *.tex chapters/*.tex

clean:
	rm -rf out/ html/
	rm -f indent.log *.bak*
