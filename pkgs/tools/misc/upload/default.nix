{ lib, stdenvNoCC, fetchFromGitHub, openssl, gcc10, gnumake, ronn}:

stdenvNoCC.mkDerivation rec {
  pname = "upload";
  version = "0.3";

  src = fetchFromGitHub {
          owner = "Zebreus";
          repo = "upload";
          rev = "v${version}";
          sha256 = "1aq86afnkq1n3i4nq5fqwmqdihrk09nw02nnn76314vbcmpaw9kk";
          fetchSubmodules = true;
  };
  
  buildInputs = [
    gcc10
    openssl
    gnumake
    ronn
  ];

  buildPhase = ''
		make dynamic INSTALL_PLUGIN_DIR=$out/lib/upload
		ronn upload.ronn --roff
  '';

  installPhase = ''
    # move executable into correct directory
    mkdir -p $out/bin
    install -m 0755 -t "$out/bin" "build-dynamic/upload"

    # move plugins into correct directory
    mkdir -p "$out/lib/upload/"
    install -m 0755 -t "$out/lib/upload/" "build/liboshi.so"
    install -m 0755 -t "$out/lib/upload/" "build/libtransfersh.so"
    install -m 0755 -t "$out/lib/upload/" "build/libnullpointer.so"
    
    # install manpage
    mkdir -p "$out/share/man/man1"
    install -m 0644 -t "$out/share/man/man1" "upload.1"
  '';
 
  meta = with lib; {
    description = "Upload files to the internet";
    homepage = "https://github.com/Zebreus/upload";
    license = licenses.gpl3;
    maintainers = with maintainers; [ zebreus ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
