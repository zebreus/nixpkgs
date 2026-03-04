{
  lib,
  coreutils,
  fakechroot,
  fakeroot,
  evalMinimalConfig,
  pkgsModule,
  python3,
  runCommand,
  util-linux,
  vmTools,
  writeText,
}:
let
  node = evalMinimalConfig (
    { config, ... }:
    {
      imports = [
        pkgsModule
        ../etc/etc.nix
      ];
      environment.etc."passwd" = {
        text = passwdText;
      };
      environment.etc."hosts" = {
        text = hostsText;
        mode = "0751";
      };
    }
  );
  passwdText = ''
    root:x:0:0:System administrator:/root:/run/current-system/sw/bin/bash
  '';
  hostsText = ''
    127.0.0.1 localhost
    ::1 localhost
    # testing...
  '';
in
lib.recurseIntoAttrs {
  test-etc-vm = vmTools.runInLinuxVM (
    runCommand "test-etc-vm" { } ''
      mkdir -p /etc
      ${node.config.system.build.etcActivationCommands}
      set -x
      [[ -L /etc/passwd ]]
      diff /etc/passwd ${writeText "expected-passwd" passwdText}
      [[ 751 = $(stat --format %a /etc/hosts) ]]
      diff /etc/hosts ${writeText "expected-hosts" hostsText}
      set +x
      touch $out
    ''
  );

  # fakeroot is behaving weird
  test-etc-fakeroot =
    runCommand "test-etc"
      {
        nativeBuildInputs = [
          fakeroot
          fakechroot
          # for chroot
          coreutils
          # fakechroot needs getopt, which is provided by util-linux
          util-linux
        ];
        fakeRootCommands = ''
          mkdir -p /etc
          ${node.config.system.build.etcActivationCommands}
          diff /etc/hosts ${writeText "expected-hosts" hostsText}
          touch $out
        '';
      }
      ''
        mkdir fake-root
        export FAKECHROOT_EXCLUDE_PATH=/dev:/proc:/sys:${builtins.storeDir}:$out
        if [ -e "$NIX_ATTRS_SH_FILE" ]; then
          export FAKECHROOT_EXCLUDE_PATH=$FAKECHROOT_EXCLUDE_PATH:$NIX_ATTRS_SH_FILE
        fi
        fakechroot fakeroot chroot $PWD/fake-root bash -e -c '
          if [ -e "$NIX_ATTRS_SH_FILE" ]; then . "$NIX_ATTRS_SH_FILE"; fi
          source $stdenv/setup
          eval "$fakeRootCommands"
        '
      '';

  # Test that files with mode specified without leading zero don't become FIFOs in the composefs dump
  test-etc-overlay-file-mode =
    let
      testSource = writeText "test-etc-overlay-source" "test content";
      testConfig = writeText "test-etc-overlay-config" (builtins.toJSON [
        {
          target = "test-file";
          source = "${testSource}";
          mode = "644";
          uid = 0;
          gid = 0;
        }
      ]);
    in
    runCommand "test-etc-overlay-file-mode" { nativeBuildInputs = [ python3 ]; } ''
      python3 ${./build-composefs-dump.py} ${testConfig} > dump.txt
      grep -q " 100644 " dump.txt || (echo "ERROR: Expected regular file mode 100644 in composefs dump:" && cat dump.txt && exit 1)
      touch $out
    '';

}
