#!/bin/bash
#


function render() {
 cat symbiota-support-hub-2023-09-11.md\
 | pandoc -s --to ${1} --filter=pandoc-citeproc -o -\
 > symbiota-support-hub-2023-09-11.${1}
}

render docx
render pdf
render rtf
