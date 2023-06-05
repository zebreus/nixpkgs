{ pkgs, lib, stdenv, makeWrapper, runCommand, nodejs, callPackage }:

let
  asciidoctorJsPackages = import ./packages
    {
      inherit pkgs lib nodejs stdenv;
    };
in

runCommand "asciidoctor-js"
  {
    buildInputs = [ makeWrapper ];
  } ''
  mkdir -p $out/bin

  makeWrapper ${lib.getExe asciidoctorJsPackages.asciidoctor} $out/bin/asciidoctor-js \
  --suffix NODE_PATH : ${asciidoctorJsPackages."asciidoctor-kroki"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctorJsPackages."@deepsymmetry/asciidoctor-bytefield"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctorJsPackages."asciidoctor-chart"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctorJsPackages."asciidoctor-color"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctorJsPackages."asciidoctor-emoji"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctorJsPackages."asciidoctor-caniuse"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctorJsPackages."asciidoctor-tweet"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctorJsPackages."asciidoctor-extension-interactive-runner"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctorJsPackages."@djencks/asciidoctor-mathjax"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctorJsPackages."@djencks/asciidoctor-template"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctorJsPackages."@djencks/asciidoctor-openblock"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctorJsPackages."@djencks/asciidoctor-glossary"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctorJsPackages."@djencks/asciidoctor-highlight.js-build-time"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctorJsPackages."asciidoctor-shiki"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctorJsPackages."asciidoctor-liquibase"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctorJsPackages."asciidoctor-interdoc-reftext"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctorJsPackages."@mvik/asciidoctor-hill-chart"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctorJsPackages."asciidoctor-highlight.js"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctorJsPackages."@springio/asciidoctor-extensions"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctorJsPackages."asciidoctor-katex"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctorJsPackages."asciidoctor-jira"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctorJsPackages."asciidoctor-prism-extension"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctorJsPackages."asciidoctor-external-callout"}/lib/node_modules \
  --suffix NODE_PATH : ${asciidoctorJsPackages."@asciidoctor/tabs"}/lib/node_modules
''
  // {
  pkgs = asciidoctorJsPackages;
}
