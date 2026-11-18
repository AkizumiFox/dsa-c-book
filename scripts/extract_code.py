#!/usr/bin/env python3
"""從各章的 chapter.tex 抽出範例程式與輸入輸出範例。

抽出的對象：標題以 (檔名.c) 開頭的 example 環境。如果 example 後面
（中間只隔空白）緊接著 \\iosample{輸入}{輸出}，也一起抽出成 .in／.out。
code 環境（片語、程式片段）和 pseudo 環境（虛擬碼）不抽。

用法：
    python3 scripts/extract_code.py --out build/code src/chapters/01_Analysis/chapter.tex
輸出：build/code/ch07/<檔名>.cpp、<檔名>.in、<檔名>.out
"""
import argparse
import pathlib
import re
import sys

EXAMPLE_RE = re.compile(
    r"\\begin\{example\}(?:\[[^\]]*\])?\{(?P<lang>[^}]*)\}\{\((?P<name>[^)]*)\)[^\n]*\n"
    r"(?P<body>.*?)\\end\{example\}",
    re.S,
)


def read_group(s, i):
    """s[i] 必須是 '{'，回傳 (群組內容, 結束後的位置)。處理巢狀大括號與 \\{ \\}。"""
    assert s[i] == "{"
    depth = 0
    j = i
    while j < len(s):
        c = s[j]
        if c == "\\":
            j += 2
            continue
        if c == "{":
            depth += 1
        elif c == "}":
            depth -= 1
            if depth == 0:
                return s[i + 1 : j], j + 1
        j += 1
    raise ValueError("unbalanced braces")


def tex_to_text(t):
    """把 \\iosample 裡的 LaTeX 寫法換回純文字，每行以 \\\\ 分隔。"""
    lines = []
    for raw in re.split(r"\\\\", t):
        line = raw.strip()
        if not line:
            continue
        line = line.replace(r"\textbackslash{}", "\\")
        line = re.sub(r"\\([#_%&${}])", r"\1", line)
        line = line.replace(r"\ ", " ").replace("~", " ")
        lines.append(line)
    return "".join(l + "\n" for l in lines)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", required=True)
    ap.add_argument("files", nargs="+")
    args = ap.parse_args()
    total = 0
    for f in args.files:
        path = pathlib.Path(f)
        m = re.match(r"(\d+)_", path.parent.name)
        chap = f"ch{m.group(1)}" if m else path.parent.name
        outdir = pathlib.Path(args.out) / chap
        outdir.mkdir(parents=True, exist_ok=True)
        src = path.read_text(encoding="utf-8")
        for ex in EXAMPLE_RE.finditer(src):
            name = ex.group("name").replace(r"\_", "_")
            if not name.endswith(".c"):
                continue
            (outdir / name).write_text(ex.group("body"), encoding="utf-8")
            stem = outdir / name[:-2]
            for ext in (".in", ".out"):
                p = stem.with_suffix(ext)
                if p.exists():
                    p.unlink()
            rest = src[ex.end():]
            k = len(rest) - len(rest.lstrip())
            if rest[k:].startswith(r"\iosample"):
                pos = k + len(r"\iosample")
                inp, pos = read_group(rest, pos)
                while rest[pos].isspace():
                    pos += 1
                out, pos = read_group(rest, pos)
                stem.with_suffix(".in").write_text(tex_to_text(inp), encoding="utf-8")
                stem.with_suffix(".out").write_text(tex_to_text(out), encoding="utf-8")
            total += 1
    print(f"extracted {total} example(s) into {args.out}", file=sys.stderr)


if __name__ == "__main__":
    main()
