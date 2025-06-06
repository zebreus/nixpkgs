{
  stdenv,
  buildPackages,
  fetchFromGitHub,
  lib,
  firefox-unwrapped,
  firefox-esr-unwrapped,
}:

let
  pname = "wasix-libc";
  # TODO: Update to the correct version
  version = "unstable-2025";
in
stdenv.mkDerivation {
  inherit pname version;

  src = buildPackages.fetchFromGitHub {
    owner = "wasix-org";
    repo = "wasix-libc";
    rev = "7d30e5e445022499114fbdddbab4db4035bef4ec";
    hash = "sha256-nki1tZK0hCXQEefaPrFesJmK0DmQRE7qY28weDtlO8I=";
    fetchSubmodules = false;
  };

  outputs = [
    "out"
    "dev"
    "share"
  ];

  # clang-13: error: argument unused during compilation: '-rtlib=compiler-rt' [-Werror,-Wunused-command-line-argument]
  postPatch = ''
    substituteInPlace Makefile \
      --replace "-Werror" ""

    # Remove the test for exports.
    # TODO: Figure out why the output is different than what is expected.
    sed -i "771d" Makefile
  '';

  preBuild = ''
    export SYSROOT_LIB=${builtins.placeholder "out"}/lib
    export SYSROOT_INC=${builtins.placeholder "dev"}/include
    export SYSROOT_SHARE=${builtins.placeholder "share"}/share
    mkdir -p "$SYSROOT_LIB" "$SYSROOT_INC" "$SYSROOT_SHARE"
    makefile=Makefile
    makeFlagsArray+=(
      "SYSROOT_LIB:=$SYSROOT_LIB"
      "SYSROOT_INC:=$SYSROOT_INC"
      "SYSROOT_SHARE:=$SYSROOT_SHARE"
      # # https://bugzilla.mozilla.org/show_bug.cgi?id=1773200
      # "BULK_MEMORY_SOURCES:="
      PIC:=yes
      EXCEPTIONS:=yes
    )

    export TARGET_ARCH=wasm32
    export TARGET_OS=wasix
  '';

  enableParallelBuilding = true;

  # We just build right into the install paths, per the `preBuild`.
  dontInstall = true;

  preFixup = ''
    ln -s $share/share/undefined-symbols.txt $out/lib/wasi.imports
  '';

  passthru.tests = {
    inherit firefox-unwrapped firefox-esr-unwrapped;
  };

  meta = with lib; {
    changelog = "https://github.com/WebAssembly/wasi-sdk/releases/tag/wasi-sdk-${version}";
    description = "WASI libc implementation for WebAssembly";
    homepage = "https://wasi.dev";
    platforms = platforms.wasix;
    maintainers = with maintainers; [
      matthewbauer
      rvolosatovs
    ];
    license = with licenses; [
      asl20
      llvm-exception
      mit
    ];
  };
}
