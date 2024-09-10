#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Please specify filename without filetype"
    exit 1
fi

engine=pdflatex

skip_bibtex=0

for arg in "$@"; do
    case "$arg" in
    --skip-bibtex)
        skip_bibtex=1
        ;;
    --engine=*)
        engine="${arg#*=}"
        ;;
    esac
done

case "$engine" in
pdfTeX|pdflatex)
    engine="pdflatex --shell-escape"
    ;;
XeTeX|xelatex)
    engine="xelatex --shell-escape"
    ;;
LuaTeX|lualatex)
    engine="lualatex --shell-escape"
    ;;
*)
    echo "Invalid engine specified. Use one of: pdfTeX, XeTeX, LuaTeX"
    exit 2
    ;;
esac

$engine $1.tex

if [ "$skip_bibtex" -eq 0 ]; then
    bibtex $1
    $engine $1.tex
fi

$engine $1.tex
