// sioyek inverse search -> VS Code 런처 (Windows 전용, Windows Script Host / JScript).
//
// 왜 필요한가: 최근 VS Code 의 Code.exe 는 -r/-g 를 직접 받지 않고("bad option"), 진짜 CLI 인
// bin\code.cmd 는 배치 파일이라 sioyek 이 실행할 때마다 콘솔 창이 깜빡인다. wscript 는 콘솔이 없고
// WshShell.Run(..., 0) 은 code.cmd 를 숨김 창으로 띄우므로 둘 다 피할 수 있다.
//
// 설치: 이 파일을 %APPDATA%\sioyek\vscode-goto.js 로 복사하고 prefs_user.config 에 한 줄:
//   inverse_search_command wscript //B //E:jscript "C:\Users\<me>\AppData\Roaming\sioyek\vscode-goto.js" "%1" %2
// (sioyek 은 설정을 시작할 때만 읽으므로 완전히 종료 후 다시 열 것)
//
// 사용: wscript //B //E:jscript vscode-goto.js <file> <line>
//
// //E:jscript 는 필수다. WSH 는 스크립트 엔진을 "파일 확장자"로 고른다. 다른 앱이 레지스트리 HKCR 의 .js 연결을
// 가져갔거나 비워 두면 "There is no script engine for file extension .js" 로 실패하는데,
// wscript //B 는 에러 창조차 띄우지 않아 inverse search 가 조용히 먹통이 된다.
// //E:jscript 로 엔진을 직접 지정하면 확장자 연결과 무관하게 동작한다.
var args = WScript.Arguments;
if (args.length < 2) {
    WScript.Quit(2);
}
var file = args(0);
var line = args(1);
var shell = WScript.CreateObject("WScript.Shell");
// 0 = 숨김 창, false = 기다리지 않음. `code` 는 PATH 의 bin\code.cmd 로 해석된다.
shell.Run('cmd /c code -r -g "' + file + ':' + line + '"', 0, false);
