#!/bin/bash
#


function render() {
cat "${1}.md"\
 | pandoc --embed-resources --toc -s --to ${2} --citeproc -o -\
 > "${1}.${2}"
}

function render_all() {
  render ${1} docx
  render ${1} pdf
  render ${1} rtf
  render ${1} html
}

render_all README
render_all symbiota-support-hub-2023-09-11
