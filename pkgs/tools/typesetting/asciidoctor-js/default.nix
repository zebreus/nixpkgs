{ pkgs, lib, stdenv, makeWrapper, runCommand, nodejs, callPackage, extensions ? [ ] }:

let
  asciidoctorJsPackages = import ./packages
    {
      inherit pkgs lib nodejs stdenv;
    };

  makeNodeModulesPath = lib.makeSearchPathOutput "lib/node_modules" "lib/node_modules";

  default-extensions = [
    asciidoctorJsPackages."asciidoctor-html5s"
    asciidoctorJsPackages."@asciidoctor/manpage-converter"
    asciidoctorJsPackages."@asciidoctor/docbook-converter"
    asciidoctorJsPackages."asciidoctor-jupyter"
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
    asciidoctorJsPackages."asciidoctor-highlight.js"
    asciidoctorJsPackages."@springio/asciidoctor-extensions"
    asciidoctorJsPackages."asciidoctor-katex"
    asciidoctorJsPackages."asciidoctor-jira"
    asciidoctorJsPackages."asciidoctor-prism-extension"
    asciidoctorJsPackages."asciidoctor-external-callout"
    asciidoctorJsPackages."@asciidoctor/tabs"
  ];

  wrapWithAsciidoctorJsPlugins = { base, extensions, name ? (lib.getName base), meta ? (base.meta or { }) }:
    runCommand
      name
      {
        inherit (base) version;
        inherit meta name;
        buildInputs = [ makeWrapper ];
      } ''
      mkdir -p $out/bin
      makeWrapper ${lib.getExe base} $out/bin/${meta.mainProgram or name} --suffix NODE_PATH : ${makeNodeModulesPath extensions}
    '';

  asciidoctor-js = wrapWithAsciidoctorJsPlugins { base = asciidoctorJsPackages."asciidoctor"; extensions = default-extensions; };
  # The npm package is called asciidoctor-pdf but the upstream project and the executable are called asciidoctor-web-pdf
  asciidoctor-web-pdf = wrapWithAsciidoctorJsPlugins { base = asciidoctorJsPackages."asciidoctor-pdf"; name = "asciidoctor-web-pdf"; extensions = default-extensions; };
  # The npm package is called asciidoctor-reveal.js but the upstream executable is called asciidoctor-revealjs
  asciidoctor-revealjs = wrapWithAsciidoctorJsPlugins { base = asciidoctorJsPackages."@asciidoctor/reveal.js"; name = "asciidoctor-revealjs"; extensions = default-extensions ++ [ asciidoctorJsPackages."asciidoctor" ]; };
in
asciidoctor-js
  // {
  pkgs = asciidoctorJsPackages;
  asciidoctor-js = asciidoctor-js;
  asciidoctor-web-pdf = asciidoctor-web-pdf;
  asciidoctor-revealjs = asciidoctor-revealjs;
  default-extensions = default-extensions;
}
