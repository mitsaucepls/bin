#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Please specify filename without filetype"
    exit 1
fi

pdflatex --shell-escape $1.tex
bibtex $1
pdflatex --shell-escape $1.tex
pdflatex --shell-escape $1.tex
