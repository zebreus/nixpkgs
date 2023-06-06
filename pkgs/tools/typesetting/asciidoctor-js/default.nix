{ pkgs, lib, stdenv, makeWrapper, runCommand, nodejs, callPackage, chromium }:

let
  asciidoctorJsPackages = import ./packages
    {
      inherit pkgs lib nodejs stdenv;
    };

  makeNodeModulesPath = lib.makeSearchPathOutput "lib/node_modules" "lib/node_modules";

  allExtensions = lib.getAttrs [
    "asciidoctor-pdf"
    "@asciidoctor/core"
    "@asciidoctor/reveal.js"
    "@asciidoctor/manpage-converter"
    "@asciidoctor/docbook-converter"
    "asciidoctor-jupyter"
    "asciidoctor-html5s"
    "asciidoctor-kroki"
    "@deepsymmetry/asciidoctor-bytefield"
    "asciidoctor-chart"
    "asciidoctor-color"
    "asciidoctor-emoji"
    "asciidoctor-extension-interactive-runner"
    "@djencks/asciidoctor-mathjax"
    "@djencks/asciidoctor-template"
    "@djencks/asciidoctor-openblock"
    "asciidoctor-shiki"
    "asciidoctor-liquibase"
    "@djencks/asciidoctor-glossary"
    "asciidoctor-interdoc-reftext"
    "@djencks/asciidoctor-highlight.js-build-time"
    "asciidoctor-highlight.js"
    "@springio/asciidoctor-extensions"
    "asciidoctor-katex"
    "asciidoctor-jira"
    "asciidoctor-prism-extension"
    "asciidoctor-external-callout"
    "@asciidoctor/tabs"
    "asciidoctor-caniuse"
    "asciidoctor-tweet"
  ]
    asciidoctorJsPackages;

  defaultExtensions = [
    allExtensions."asciidoctor-html5s"
    allExtensions."@asciidoctor/manpage-converter"
    allExtensions."@asciidoctor/docbook-converter"
    allExtensions."asciidoctor-jupyter"
    allExtensions."asciidoctor-kroki"
    allExtensions."@deepsymmetry/asciidoctor-bytefield"
    allExtensions."asciidoctor-chart"
    allExtensions."asciidoctor-color"
    allExtensions."asciidoctor-emoji"
    allExtensions."asciidoctor-extension-interactive-runner"
    allExtensions."@djencks/asciidoctor-mathjax"
    allExtensions."@djencks/asciidoctor-template"
    allExtensions."@djencks/asciidoctor-openblock"
    allExtensions."asciidoctor-shiki"
    allExtensions."asciidoctor-liquibase"
    allExtensions."@djencks/asciidoctor-glossary"
    allExtensions."asciidoctor-interdoc-reftext"
    allExtensions."@djencks/asciidoctor-highlight.js-build-time"
    allExtensions."asciidoctor-highlight.js"
    allExtensions."@springio/asciidoctor-extensions"
    allExtensions."asciidoctor-katex"
    allExtensions."asciidoctor-jira"
    allExtensions."asciidoctor-prism-extension"
    allExtensions."asciidoctor-external-callout"
    allExtensions."@asciidoctor/tabs"
    allExtensions."asciidoctor-caniuse"
  ];

  wrapWithAsciidoctorJsPlugins = lib.makeOverridable ({ base, extensions ? defaultExtensions, name ? (lib.getName base), meta ? (base.meta or { }) }:
    runCommand
      name
      rec {
        inherit (base) version;
        inherit meta name;
        buildInputs = [ makeWrapper ];
      } ''
      mkdir -p $out/bin
      makeWrapper ${lib.getExe base} $out/bin/${meta.mainProgram or name} \
        --suffix NODE_PATH : "${makeNodeModulesPath extensions}" \
        --set-default PUPPETEER_EXECUTABLE_PATH "${lib.getExe chromium}"
    '');

  asciidoctor-js = wrapWithAsciidoctorJsPlugins { base = asciidoctorJsPackages."asciidoctor"; };
  # The npm package is called asciidoctor-pdf but the upstream project and the executable are called asciidoctor-web-pdf
  asciidoctor-web-pdf = wrapWithAsciidoctorJsPlugins { base = asciidoctorJsPackages."asciidoctor-pdf"; name = "asciidoctor-web-pdf"; };
  # The npm package is called asciidoctor-reveal.js but the upstream executable is called asciidoctor-revealjs
  asciidoctor-revealjs = wrapWithAsciidoctorJsPlugins { base = asciidoctorJsPackages."@asciidoctor/reveal.js"; name = "asciidoctor-revealjs"; };
in
asciidoctor-js
  // {
  pkgs = asciidoctorJsPackages;
  asciidoctor-js = asciidoctor-js;
  asciidoctor-web-pdf = asciidoctor-web-pdf;
  asciidoctor-revealjs = asciidoctor-revealjs;
  allExtensions = allExtensions;
  defaultExtensions = defaultExtensions;
}
