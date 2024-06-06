{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  cmake,
  freetype,
  libX11,
  libXcursor,
  libXrandr,
  libXi,
  libGL,
  pkg-config,
  autoPatchelfHook,
  libgcc,
  wrapGAppsHook4,
  makeWrapper,
}:

rustPlatform.buildRustPackage {
  pname = "pixelpwnr-server";
  version = "unstable-2024-03-13";

  src = fetchFromGitHub {
    owner = "timvisee";
    repo = "pixelpwnr-server";
    rev = "4abc3e0ef92f6444a8f7b67cb36367a304217bd7";
    hash = "sha256-RakDcxDIov+HCaxJ5Tx62aFIt+1NhdJ+J164lc4ptrI=";
  };

  cargoHash = "sha256-N3NXXIX5kzEmKTDpNzJgnSqJWNctupjm69mGYVteKIU=";

  nativeBuildInputs = [
    cmake
    pkg-config
    # autoPatchelfHook
    makeWrapper
    # wrapGAppsHook4
  ];

  buildInputs = [
    freetype
    libX11
    libXcursor
    libXrandr
    libXi
    # libGL
    # libgcc
  ];

  runtimeDependencies = [ ];

  postFixup = lib.optionalString stdenv.targetPlatform.isElf ''
    # ldd $out/bin/pixelpwnr-server
    # patchelf $out/bin/pixelpwnr-server --add-rpath $ {
    #   lib.makeLibraryPath [
    #     libGL
    #     libX11
    #     libXcursor
    #     libXrandr
    #     libXi
    #   ]
    # }
    # ldd $out/bin/pixelpwnr-server
  '';

  postInstall = ''
    ldd $out/bin/pixelpwnr-server
    # patchelf $out/bin/pixelpwnr-server \
    #   --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
    #   $out/bin/pixelpwnr-server
    patchelf $out/bin/pixelpwnr-server --add-needed libGL.so --add-rpath \
      ${lib.makeLibraryPath [ libGL ]}
    # wrapProgram $out/bin/pixelpwnr-server \
    #     --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libGL ]}
  '';

  doCheck = false;
  # buildInputs = [
  #   freetype
  #   libX11
  #   libXcursor
  #   libXrandr
  #   libXi
  #   libGL
  #   libgcc
  # ];

  # postInstall = ''
  #   ldd $out/bin/pixelpwnr-server
  #   wrapProgram $out/bin/pixelpwnr-server \
  #       --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libGL ]}
  # '';

  meta = with lib; {
    homepage = "https://timvisee.com/projects/pixelpwnr-server";
    description = "Blazingly fast GPU accelerated pixelflut server written in Rust";
    license = licenses.gpl3;
    mainProgram = "pixelpwnr-server";
  };
}
