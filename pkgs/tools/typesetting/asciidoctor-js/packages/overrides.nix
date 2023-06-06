# Do not use overrides in this file to add  `meta.mainProgram` to packages. Use `./main-programs.nix`
# instead.
{ pkgs, nodejs }:

let
  inherit (pkgs)
    stdenv
    lib
    callPackage
    fetchFromGitHub
    fetchurl
    fetchpatch
    nixosTests;

  since = version: lib.versionAtLeast nodejs.version version;
  before = version: lib.versionOlder nodejs.version version;
in

final: prev: {
  asciidoctor-pdf = prev.asciidoctor-pdf.override (oldAttrs: {
    nativeBuildInputs = [ pkgs.buildPackages.makeWrapper ];
    prePatch = ''
      export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1
    '';
    postInstall = ''
      ASCIIDOCTOR_WEB_PDF=`readlink -f $out/bin/asciidoctor-web-pdf`
      ASCIIDOCTOR_PDF=`readlink -f $out/bin/asciidoctor-pdf`
      rm $out/bin/asciidoctor-web-pdf
      rm $out/bin/asciidoctor-pdf
      makeWrapper "$ASCIIDOCTOR_WEB_PDF" $out/bin/asciidoctor-web-pdf --set-default PUPPETEER_EXECUTABLE_PATH "${lib.getExe pkgs.chromium}"
      makeWrapper "$ASCIIDOCTOR_PDF" $out/bin/asciidoctor-pdf --set-default PUPPETEER_EXECUTABLE_PATH "${lib.getExe pkgs.chromium}"
    '';
  });

  asciidoctor = prev.asciidoctor.override (oldAttrs: {
    nativeBuildInputs = [ pkgs.buildPackages.makeWrapper ];
    prePatch = ''
      export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1
    '';
    postInstall = ''
      ASCIIDOCTOR=`readlink -f $out/bin/asciidoctor`
      ASCIIDOCTORJS=`readlink -f $out/bin/asciidoctorjs`
      rm $out/bin/asciidoctor
      rm $out/bin/asciidoctorjs
      makeWrapper "$ASCIIDOCTOR" $out/bin/asciidoctor --set-default PUPPETEER_EXECUTABLE_PATH "${lib.getExe pkgs.chromium}"
      makeWrapper "$ASCIIDOCTORJS" $out/bin/asciidoctorjs --set-default PUPPETEER_EXECUTABLE_PATH "${lib.getExe pkgs.chromium}"
    '';
  });

  "@mvik/asciidoctor-hill-chart" = prev."@mvik/asciidoctor-hill-chart".override (oldAttrs: {
    nativeBuildInputs = [ pkgs.pkg-config nodejs.pkgs.node-pre-gyp ];
    # These dependencies are required by
    # https://github.com/Automattic/node-canvas.
    buildInputs = with pkgs; [
      giflib
      pixman
      cairo
      pango
    ] ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.CoreText
    ];
  });




}
