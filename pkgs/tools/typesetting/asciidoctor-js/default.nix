{ pkgs, lib, stdenv, makeWrapper, runCommand, nodejs, callPackage }:

let
  asciidoctorJsPackages = import ./packages
    {
      inherit pkgs lib nodejs stdenv;
    };

  makeNodeModulesPath = lib.makeSearchPathOutput "lib/node_modules" "lib/node_modules";

  plugins = [
    asciidoctorJsPackages."asciidoctor-kroki"
    asciidoctorJsPackages."@deepsymmetry/asciidoctor-bytefield"
    asciidoctorJsPackages."asciidoctor-chart"
    asciidoctorJsPackages."asciidoctor-color"
    asciidoctorJsPackages."asciidoctor-emoji"
    asciidoctorJsPackages."asciidoctor-caniuse"
    asciidoctorJsPackages."asciidoctor-tweet"
    asciidoctorJsPackages."asciidoctor-extension-interactive-runner"
    asciidoctorJsPackages."@djencks/asciidoctor-mathjax"
    asciidoctorJsPackages."@djencks/asciidoctor-template"
    asciidoctorJsPackages."@djencks/asciidoctor-openblock"
    asciidoctorJsPackages."@djencks/asciidoctor-glossary"
    asciidoctorJsPackages."@djencks/asciidoctor-highlight.js-build-time"
    asciidoctorJsPackages."asciidoctor-shiki"
    asciidoctorJsPackages."asciidoctor-liquibase"
    asciidoctorJsPackages."asciidoctor-interdoc-reftext"
    asciidoctorJsPackages."@mvik/asciidoctor-hill-chart"
    asciidoctorJsPackages."asciidoctor-highlight.js"
    asciidoctorJsPackages."@springio/asciidoctor-extensions"
    asciidoctorJsPackages."asciidoctor-katex"
    asciidoctorJsPackages."asciidoctor-jira"
    asciidoctorJsPackages."asciidoctor-prism-extension"
    asciidoctorJsPackages."asciidoctor-external-callout"
    asciidoctorJsPackages."@asciidoctor/tabs"
  ];

  wrapWithAsciidoctorJsPlugins = { base, plugins, name ? (lib.getName base), meta ? (base.meta or { }) }:
    runCommand
      name
      {
        inherit (base) version;
        inherit meta name;
        buildInputs = [ makeWrapper ];
      } ''
      mkdir -p $out/bin
      makeWrapper ${lib.getExe base} $out/bin/${meta.mainProgram or name} --suffix NODE_PATH : ${makeNodeModulesPath plugins}
    '';

  asciidoctor-js = wrapWithAsciidoctorJsPlugins { base = asciidoctorJsPackages."asciidoctor"; inherit plugins; };
  asciidoctor-web-pdf = wrapWithAsciidoctorJsPlugins { base = asciidoctorJsPackages."asciidoctor-pdf"; name = "asciidoctor-web-pdf"; inherit plugins; };
in
asciidoctor-js
  // {
  pkgs = asciidoctorJsPackages;
  asciidoctor-js = asciidoctor-js;
  asciidoctor-web-pdf = asciidoctor-web-pdf;
}
