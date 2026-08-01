# ColdArchive

Mac storage, the way iPhone Photos does it — files you don't use move to your
cloud or an external drive, and a shortcut stays where the file was.

**→ https://deep-on.github.io/coldarchive/**

## The restore script is here too

ColdArchive moves a file and leaves a symlink. Alongside the files it writes
[`RESTORE-ME.command`](restore/) — a 187-line POSIX `sh` script that puts everything back.

It needs `sh` and `mv`. Not this app, not the internet, not even the Mac you started on.
It is published so you can read it before trusting it, and so it keeps working if we don't.
Public domain — [take it](restore/README.md).

ColdArchive itself is a paid macOS app; its source is not published here.

- [English](https://deep-on.github.io/coldarchive/)
- [한국어](https://deep-on.github.io/coldarchive/ko/)
- [日本語](https://deep-on.github.io/coldarchive/ja/)
- [Deutsch](https://deep-on.github.io/coldarchive/de/)
- [Français](https://deep-on.github.io/coldarchive/fr/)
- [Español](https://deep-on.github.io/coldarchive/es/)

Questions and bug reports: [Issues](https://github.com/deep-on/coldarchive/issues)
