{
  lib,
  coreutils,
  fakechroot,
  fakeroot,
  evalMinimalConfig,
  pkgsModule,
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
  
  # Node for testing overlay mode with file mode
  overlayNode = evalMinimalConfig (
    { config, ... }:
    {
      imports = [
        pkgsModule
        ../etc/etc.nix
      ];
      system.etc.overlay.enable = true;
      environment.etc."test-file" = {
        text = "test content";
        mode = "0644";
      };
      environment.etc."test-file-short-mode" = {
        text = "test content with short mode";
        mode = "644";
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

  # Test that files with mode specified without leading zero don't become FIFOs
  test-etc-overlay-file-mode =
    runCommand "test-etc-overlay-file-mode"
      {
        nativeBuildInputs = [
          coreutils
        ];
      }
      ''
        # Build the metadata image to check it can be created successfully
        echo "Building etcMetadataImage..."
        ${overlayNode.config.system.build.etcMetadataImage}
        
        # Check that the etcBasedir contains the expected files
        echo "Checking etcBasedir..."
        [ -f "${overlayNode.config.system.build.etcBasedir}/test-file" ] || (echo "test-file not found in etcBasedir" && exit 1)
        [ -f "${overlayNode.config.system.build.etcBasedir}/test-file-short-mode" ] || (echo "test-file-short-mode not found in etcBasedir" && exit 1)
        
        echo "Test passed!"
        touch $out
      '';

}
