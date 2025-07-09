# 📦 `unp-wrapper.sh`

## Overview
`unp-wrapper.sh` is a smart, POSIX-compliant shell script that wraps around [`unp`](https://packages.debian.org/unp), the archive extraction tool. It safely extracts files into uniquely named folders, handles collision scenarios, and cleans up temporary directories. This script avoids cluttering the current working directory and is suitable for automation, scripting workflows, or everyday archive unpacking with enhanced structure.

---

## 🚀 Features

- Unpacks a wide variety of archive types using `unp`
- Extracts into a temporary directory and safely renames based on archive name
- Handles complex and compound extensions (e.g. `.tar.gz.bak~`)
- Avoids overwriting existing directories via auto-incremented naming (`.unp.N`)
- Detects whether an archive contains a single folder matching the archive name or multiple/unrelated contents
- Supports optional unpacking to `/tmp` via `-t` flag
- Performs strict sanity checks and handles edge cases gracefully
- Fully POSIX-compliant; uses `command -v`, `realpath`, and shell-safe conditionals

---

## 💡 Suggested Setup

To make the script easily accessible and feel like a native tool:

1. Move the script to your system's binary directory:
   ```sh
   sudo mv unp-wrapper.sh /usr/local/bin/unpk
   ```
2. Make it executable:
   ```sh
   sudo chmod a+x /usr/local/bin/unpk
   ```
3. Now you can run it from anywhere just like `unp`:
   ```sh
   unpk myarchive.zip
   ```

---

## 🧰 Usage

```sh
./unp-wrapper.sh [options] <archive>
```

### Options:
- `-t` → extract into `/tmp` instead of current directory
- `-h` → show help and exit

### Examples:
```sh
./unp-wrapper.sh myarchive.zip
./unp-wrapper.sh -t ~/Downloads/project.tar.gz
```

After running, if:
- The archive contains a single folder **named** like the archive, it will be unpacked directly as `./myarchive/`
- If the archive contains multiple files, or a sole folder with a different name, everything is placed inside a new folder named after the archive (`./myarchive/`)

If `./myarchive` already exists, the script will create `./myarchive.unp.0`, `./myarchive.unp.1`, etc.

---

## 🛡 Requirements

- Shell: POSIX-compliant (`sh`, `dash`, etc.)
- `unp` must be installed and available in `$PATH`
- `realpath` utility (included on most Unix-like systems)

---

## 🗃 Supported Extensions

Handles suffix chains like:
```
.tar.gz, .tar.xz, .tbz2.bak~, .zip, .rar, .7z, .tgz, .txz, .lz, .lzop, .lzip, .cab, .dmg, .zst, .cpio, .backup~
```
…and many more.

Suffix stripping includes known archive formats plus `.bak`, `.backup`, and trailing `~`.

---

## 🔧 License & Authorship

This script was collaboratively developed with the support of Microsoft Copilot.  
It is freely distributable and modifiable—attribution appreciated but not required.
