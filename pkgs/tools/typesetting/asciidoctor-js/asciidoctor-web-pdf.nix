{ lib, makeWrapper, runCommand, asciidoctor-js }:

runCommand "asciidoctor-web-pdf"
{
  buildInputs = [ makeWrapper ];
} ''
  mkdir -p $out/bin

  makeWrapper ${lib.getExe asciidoctor-js.pkgs.asciidoctor-pdf} $out/bin/asciidoctor-web-pdf \
  --suffix NODE_PATH : ${asciidoctor-js.pkgs."asciidoctor-kroki"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctor-js.pkgs."@deepsymmetry/asciidoctor-bytefield"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctor-js.pkgs."asciidoctor-chart"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctor-js.pkgs."asciidoctor-color"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctor-js.pkgs."asciidoctor-emoji"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctor-js.pkgs."asciidoctor-caniuse"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctor-js.pkgs."asciidoctor-tweet"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctor-js.pkgs."asciidoctor-extension-interactive-runner"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctor-js.pkgs."@djencks/asciidoctor-mathjax"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctor-js.pkgs."@djencks/asciidoctor-template"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctor-js.pkgs."@djencks/asciidoctor-openblock"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctor-js.pkgs."@djencks/asciidoctor-glossary"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctor-js.pkgs."@djencks/asciidoctor-highlight.js-build-time"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctor-js.pkgs."asciidoctor-shiki"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctor-js.pkgs."asciidoctor-liquibase"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctor-js.pkgs."asciidoctor-interdoc-reftext"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctor-js.pkgs."@mvik/asciidoctor-hill-chart"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctor-js.pkgs."asciidoctor-highlight.js"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctor-js.pkgs."@springio/asciidoctor-extensions"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctor-js.pkgs."asciidoctor-katex"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctor-js.pkgs."asciidoctor-jira"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctor-js.pkgs."asciidoctor-prism-extension"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctor-js.pkgs."asciidoctor-external-callout"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctor-js.pkgs."@asciidoctor/tabs"}/lib/node_modules
''
