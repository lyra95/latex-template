.PHONY: pdf html clean format all

all: pdf html

pdf:
	latexmk -xelatex -synctex=1 -interaction=nonstopmode -file-line-error -outdir=out main.tex

html:
	mkdir -p html
	pandoc main.tex -s -o html/index.html \
		--katex="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/" \
		--toc \
		--metadata title="LaTeX Template with Korean Support"
	@echo "HTML generated: html/index.html"
	@echo "Open with: \$$BROWSER html/index.html"

format:
	latexindent -w **/*.tex

clean:
	rm -rf out/
	rm -f chapters/*.aux
	rm -rf html/