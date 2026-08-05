# ColdArchive

Mac storage, the way iPhone Photos does it — files you don't use move to your
cloud or an external drive, and a shortcut stays where the file was.

**→ https://coldarchive.deepon.kr/**

## The restore script is here too

ColdArchive moves a file and leaves a symlink. Alongside the files it writes
[`RESTORE-ME.command`](restore/) — a 187-line POSIX `sh` script that puts everything back.

It needs `sh` and `mv`. Not this app, not the internet, not even the Mac you started on.
It is published so you can read it before trusting it, and so it keeps working if we don't.
Public domain — [take it](restore/README.md).

ColdArchive itself is a paid macOS app; its source is not published here.

- [English](https://coldarchive.deepon.kr/)
- [한국어](https://coldarchive.deepon.kr/ko/)
- [日本語](https://coldarchive.deepon.kr/ja/)
- [Deutsch](https://coldarchive.deepon.kr/de/)
- [Français](https://coldarchive.deepon.kr/fr/)
- [Español](https://coldarchive.deepon.kr/es/)

Questions and bug reports: [Issues](https://github.com/deep-on/coldarchive/issues)
