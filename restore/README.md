# RESTORE-ME

This is the script [ColdArchive](https://deep-on.github.io/coldarchive/) drops into your
archive folder. It puts every archived file back where it came from.

It is published here so you can **read it before you trust it** — and so it keeps working
if we stop existing. It needs `sh` and `mv`. Not the app, not the internet, not even the
Mac you started on.

```sh
sh RESTORE-ME.command --list      # what would be restored
sh RESTORE-ME.command --dry-run   # plan only, moves nothing
sh RESTORE-ME.command             # asks first
sh RESTORE-ME.command --yes       # no questions
```

## How it works

ColdArchive moves a file to your archive folder and leaves a symlink behind. Alongside the
files it writes `coldarchive-manifest.tsv`, three tab-separated columns:

```
~/Downloads/conference-2019.zip	Downloads/conference-2019.zip	482929645
original location            	path inside this folder     	bytes
```

The script reads that, deletes the symlink, and `mv`s the file back. That is the whole idea.

Paths are stored **relative to the archive folder**, and the original is abbreviated to `~`
rather than spelling out your home directory. So the folder can be moved, renamed, or
carried to another Mac under a different account, and restore still resolves.

## What it will not do

These are enforced in the code, not promises. Read `classify()` and the block above `mv`.

- **It never overwrites a real file.** If something already occupies the original path, that
  entry is reported `occupied` and skipped.
- **It only removes symlinks that point into this archive.** A symlink you made yourself is
  reported `foreign` and left alone.
- **It re-checks immediately before moving**, because the first pass and the move are not
  atomic and the world can change in between.
- **If `mv` fails, it puts the symlink back**, so a failure leaves you where you started.

It runs in two passes: classify everything and show you the counts, then ask, then move.

## Why it is written like this

Deliberately boring. No arrays, no `[[`, no `local` — pure POSIX `sh`, because it has to run
under whatever shell is present, including on an old system you booted to recover files.

No `jq`, no `python`, no ColdArchive. A recovery tool that has dependencies is not a
recovery tool.

The file is named `.command` so double-clicking it works in Finder. Cloud sync tends to
strip the executable bit, so it is written to also work as `sh RESTORE-ME.command` — that is
why it is `sh` and not `bash`.

## Honest limits

- **The manifest is required.** Lose it and the script cannot know where anything belongs.
  It lives next to the files, so a copy of the archive folder carries both.
- **Files stored in a cloud folder must download before they can move.** The script will
  wait on `mv` while the provider fetches them; a large archive can take a while.
- **It restores to the recorded original path.** Missing parent folders are recreated. If
  you have since reorganised your home folder, files return to where they used to live.

## Files here

| | |
|---|---|
| `RESTORE-ME.command` | the script, byte-identical to what the app installs |
| `example-manifest.tsv` | the format, with invented paths |

The app generates this from `Engine/Rescue.swift`. Same content — this copy exists so it can
be read without buying anything.

## Licence

Public domain (CC0). Copy it, vendor it, adapt it for your own tool. The point is that
nobody's files should be hostage to whether a company is still around.

ColdArchive itself is a paid macOS app; its source is not published.
