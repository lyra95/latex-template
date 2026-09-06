이 프로젝트는 latex의 지저분한 의존성 문제와 빌드 환경 문제, 그리고 끔찍한 작업 루틴을 해결하기 위해 만들어진 template 리포지토리입니다.

의존성 문제는 docker(devcontainer)로 해결하고, 빌드 환경 문제와 작업 루틴은 vs code의 latex workshop extension을 활용하여 해결했습니다.

한 가지 마이너한 이슈는, latex workshop extension이 제공하는 내장 pdf 뷰어가 별로 마음에 들지 않고, 외부 pdf 뷰어를 사용하고 싶다는 점입니다. (sioyek)

내장 pdf 뷰어는 synctex를 부분활용하여 (CJK의 경우에는 extension의 js 코드가 직접 처리하기도 한다고 들었습니다), foward search와 inverse search를 지원합니다. 외부 pdf 뷰어를 사용하면서 이 기능을 유지하고 싶습니다. 하지만 devcontainer 환경에서는 외부 pdf 뷰어를 실행하기가 어렵기 때문에 문제가 복잡해집니다.

그래서 devcontainer 환경을 포기하기로 했습니다. 대신에, latex 빌드는 docker run (혹은 상시 실행 중인 컨테이너에 exec)로 수행하려고 합니다. 이 경우에는 외부 pdf 뷰어를 자유롭게 사용할 수 있고, synctex를 활용한 forward search와 inverse search도 가능할 것으로 보입니다.

당신의 역할은 이 가능성을 직접 구현하는 것입니다. latex workshop extension을 사용하면서 외부 pdf 뷰어를 활용하고, synctex를 통한 forward search와 inverse search 기능을 유지하는 방법을 구현해주세요,

---

## 구성

```
docker/Dockerfile        texlive-full 이미지. 호스트에는 TeX를 설치하지 않는다.
scripts/latexmk.sh       컨테이너 안에서 실행되는 빌드 진입점 (latexmk + synctex 경로 치환)
scripts/fix-synctex.sh   out/main.synctex.gz 의 /work/... 경로를 호스트 경로로 바꾼다
scripts/latexindent.sh   컨테이너 안의 latexindent 로 포매팅 (LaTeX Workshop 포매터가 호출, 저장 시 자동)
scripts/vscode-goto.js   [Windows] sioyek inverse search 가 VS Code 를 띄울 때 쓰는 런처 (%APPDATA%\sioyek\ 에 복사해서 사용)
.vscode/settings.json    LaTeX Workshop: docker run 으로 빌드, sioyek 외부 뷰어, forward/inverse search
.vscode/tasks.json       이미지 빌드, 포매팅 등 가끔 쓰는 명령 (Terminal > Run Task)
Makefile                 CLI용 (make image / pdf / format / html / clean)
```

## 사전 준비 (호스트)

1. **docker** — `docker` 가 PATH 에 있는 *진짜 실행파일*이어야 한다. LaTeX Workshop 은 셸 없이 `spawn` 하므로,
   Windows 에서 `docker.cmd`/`docker.bat` 같은 스크립트 shim 은 `spawn docker ENOENT` 로 실패한다.
   (podman 을 docker 대신 쓰는 경우 `podman.exe` 를 가리키는 `docker.exe` symlink 를 두면 된다.)
2. **sioyek** — PATH 에 있어야 한다. macOS 는 `/Applications/sioyek.app/Contents/MacOS/sioyek` 전체 경로를
   `.vscode/settings.json` 의 `latex-workshop.view.pdf.external.*.command` 에 적어야 할 수 있다.
3. **VS Code + LaTeX Workshop** 확장 (`James-Yu.latex-workshop`). 레포를 열면 설치를 추천한다.
4. **sioyek inverse search 설정** — sioyek 의 `prefs_user.config` 에 VS Code 를 띄우는 명령을 적는다 (`%1` = tex 파일, `%2` = 줄).
   ```
   # Windows: scripts/vscode-goto.js 를 %APPDATA%\sioyek\ 에 복사한 뒤
   inverse_search_command wscript //B "C:\Users\<me>\AppData\Roaming\sioyek\vscode-goto.js" "%1" %2
   # macOS / Linux (`code` 가 PATH 에 있어야 한다: "Shell Command: Install 'code' command in PATH")
   inverse_search_command code -r -g "%1:%2"
   ```
   Windows 에서 런처를 거치는 이유: 최근 VS Code 의 `Code.exe` 는 `-r -g` 를 직접 받지 않고(`bad option`), `code.cmd` 를 그대로 부르면
   클릭마다 콘솔 창이 깜빡인다. `wscript`(콘솔 없음)가 `code.cmd` 를 숨김 창으로 실행해 둘 다 피한다.
   파일 위치 — Windows: `%APPDATA%\sioyek\prefs_user.config` (portable 빌드는 `sioyek.exe` 옆의 파일. 둘 다 써 두면 확실하다),
   macOS: `~/Library/Application Support/sioyek/prefs_user.config`, Linux: `~/.config/sioyek/prefs_user.config`.
   **설정을 바꾼 뒤에는 sioyek 을 완전히 종료하고 다시 열어야 한다** — 설정은 시작할 때만 읽고, 단일 인스턴스라 이후 실행은 기존 창으로 전달된다.
5. **이미지 빌드 (최초 1회, 오래 걸림)** — Terminal > Run Task > `latex: build docker image`
   (= `docker build -t latex-template docker`, 또는 `make image`).

## 사용법

| 하고 싶은 것 | 방법 |
|---|---|
| 빌드 | `.tex` 저장 (autoBuild onSave) 또는 `Ctrl+Alt+B` |
| PDF 열기 (sioyek) | `Ctrl+Alt+V` (LaTeX Workshop: View LaTeX PDF) |
| tex → pdf (forward search) | 저장하면 빌드 후 자동으로 커서 위치로 이동. 즉시 이동은 `Ctrl+Alt+J` (macOS `Cmd+Option+J`) 또는 편집기 우클릭 > *SyncTeX from cursor* |
| pdf → tex (inverse search) | sioyek 에서 `F4` 로 synctex 모드를 켜고, 본문을 **우클릭** → VS Code 해당 줄로 이동 |
| 포매팅 | 저장하면 자동 (formatOnSave, 컨테이너의 latexindent). 수동은 `Shift+Alt+F`. 전체 파일 일괄은 Run Task > `latex: format (latexindent)` 또는 `make format` |

빌드 로그는 LaTeX Workshop 의 출력 패널(`LaTeX Compiler`)에 그대로 나온다. 터미널에서 같은 명령을 돌려보려면 Run Task > `latex: build pdf` 또는 `make pdf`.

## 동작 원리

### 빌드 = docker run

LaTeX Workshop 의 recipe 가 `latexmk` 대신 다음을 실행한다 (`.vscode/settings.json`):

```
docker run --rm -v <프로젝트>:/work -w /work -e HOST_DIR=<프로젝트> latex-template sh scripts/latexmk.sh main.tex
```

컨테이너는 매 빌드마다 새로 뜨고 끝나면 사라진다 (`--rm`). 상시 실행 컨테이너에 `exec` 하는 방식은 굳이 필요하지 않았다 — 기동 비용이 1초 남짓이고, 상태를 남기지 않는 쪽이 단순하다.

### SyncTeX 경로 문제와 해결

컨테이너 안에서 컴파일하면 `out/main.synctex.gz` 에 **컨테이너 경로**가 기록된다:

```
Input:1:/work/main.tex
Input:61:/work/./chapters/ch1.tex
```

호스트의 sioyek 은 `D:\dev\latex-template\chapters\ch1.tex` 같은 호스트 경로로 forward search 를 하고,
inverse search 때는 synctex 에 적힌 경로를 그대로 `code` 에 넘긴다. 그러니 경로가 맞지 않으면 둘 다 동작하지 않는다.

`scripts/fix-synctex.sh` 가 빌드 직후 이 파일을 다시 써서 해결한다:

```
Input:1:d:/dev/latex-template/main.tex
Input:61:d:/dev/latex-template/chapters/ch1.tex
```

- `/work/` → `HOST_DIR/` 로 치환. `HOST_DIR` 은 LaTeX Workshop 의 `%WORKSPACE_FOLDER%` 가 `-e` 로 넘겨준다.
- 중간의 `./` 도 지운다. synctex 파서는 경로 *앞*의 `./` 만 무시하므로 `/work/./chapters/ch1.tex` 는
  `.../chapters/ch1.tex` 와 매치되지 않는다. (하위 디렉터리 파일에서 forward search 가 안 되는 흔한 원인.)
- 역슬래시는 슬래시로 통일한다. Windows 용 synctex 파서는 `/`·`\` 와 대소문자를 구분하지 않고 비교한다.

컨테이너 안의 `synctex` CLI 로 치환된 파일을 조회하면 forward(`synctex view -i 6:0:d:/dev/latex-template/chapters/ch1.tex -o out/main.pdf`)와 inverse(`synctex edit -o 5:200:300:out/main.pdf`) 모두 올바른 페이지/파일을 돌려준다.

### 포매팅 = docker run latexindent

LaTeX Workshop 의 포매터는 문서 내용을 같은 디렉터리의 `__latexindent_temp_<파일명>` 에 써 두고, `latexindent.path` 를 실행해
stdout 을 결과로 받는다. `latexindent.path` 를 `docker` 로, args 를 `run … latex-template sh scripts/latexindent.sh %WORKSPACE_FOLDER% %TMPFILE% …` 로
두면 컨테이너 안의 latexindent 가 쓰인다. `%TMPFILE%` 은 호스트 경로이므로 [scripts/latexindent.sh](scripts/latexindent.sh) 가 `/work/...` 로 바꿔 준다.
`"[latex]": { "editor.formatOnSave": true }` 로 저장 시 자동 포매팅 (컨테이너 기동 포함 약 1초).

### 뷰어와 LaTeX Workshop 의 연결

- `latex-workshop.view.pdf.viewer: "external"` + `external.viewer.command/args` — `Ctrl+Alt+V` 가 sioyek 을 연다.
- `external.synctex.command/args` — forward search 는 sioyek 자체 기능으로 처리한다:
  `sioyek --reuse-window --nofocus --forward-search-file %TEX% --forward-search-line %LINE% %PDF%`.
  `--nofocus` 는 저장할 때마다 sioyek 이 포커스를 훔치지 않게 한다.
- inverse search 는 sioyek 이 자기 설정(`inverse_search_command`)대로 VS Code 를 띄우는 것으로 끝난다 — synctex 안의 경로가
  이미 호스트 경로라서 그대로 열린다. 어떤 에디터를 어떻게 띄울지는 머신별 설정이므로 sioyek `prefs_user.config` 에 두고,
  settings.json 에서는 `--inverse-search` 를 넘기지 않는다 (CLI 인자가 prefs 를 덮어쓰기 때문).

## 알아둘 것

- `out/` 은 프로젝트 안에 있어야 한다. 마운트 밖(`/tmp` 등)에 두면 호스트 뷰어가 PDF 를 볼 수 없다.
- 루트 파일이 `main.tex` 가 아니면 `Makefile`/`tasks.json` 의 `main.tex` 와 `.vscode/settings.json` 의 `%RELATIVE_DOC%` 가 가리키는 파일이 같은지 확인한다.
- Linux 호스트에서 docker 로 빌드하면 `out/` 아래 파일이 root 소유가 될 수 있다. 신경 쓰이면 tool 의 args 에 `--user`, `<uid>:<gid>` 를 추가한다.
