#!/bin/bash
#


function render() {
 ls -1 | grep .md$ | grep -v README | xargs cat\
 | pandoc -s --to ${1} --citeproc -o -\
 > symbiota-support-hub-2023-09-11.${1}
}

render docx
render pdf
render rtf
render html
