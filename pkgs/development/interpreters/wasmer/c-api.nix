{
  lib,
  rustPlatform,
  fetchFromGitHub,
  llvmPackages,
  libffi,
  libxml2,
  withLLVM ? true,
  withSinglepass ? true,
}:

rustPlatform.buildRustPackage rec {
  pname = "wasmer-c-api";
  version = "6.0.1";

  src = fetchFromGitHub {
    owner = "wasmerio";
    repo = pname;
    rev = "ae8f8a105ecf8b3e9812af1684538d89eb676c8f";
    hash = "sha256-95a+oiG0nyB4G8miAC0mDPgcS/eAkxdMt6MbMK/ue90=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-vkqf/VgWz90p0IwpqxKcjwi/PSWWq8Eu2YazPikYAYw=";

  nativeBuildInputs = [
    rustPlatform.bindgenHook
  ];

  buildInputs = lib.optionals withLLVM [
    llvmPackages.llvm
    libffi
    libxml2
  ];

  # check references to `compiler_features` in Makefile on update
  buildFeatures = [
     "webc_runner"
     # "cranelift" is enabled by default
     "wasmer-artifact-create"
     "static-artifact-create"
     "wasmer-artifact-load"
     "static-artifact-load"
    ]
    ++ lib.optional withLLVM "llvm"
    ++ lib.optional withSinglepass "singlepass";

  cargoBuildFlags = [
    "--manifest-path"
    "lib/c-api/Cargo.toml"
  ];

  auditable = false;

  postInstall = ''
	  for header in lib/c-api/*.h; do install -Dm644 "$header" $out/include/$(basename $header); done
    printf "prefix=$out\nincludedir=\044{prefix}/include\nlibdir=\044{prefix}/lib\n\nName: wasmer\nDescription: The Wasmer library for running WebAssembly\nVersion: ${version}\nCflags: -I\044{includedir}\nLibs: -L\044{libdir} -lwasmer\n" | install -Dm644 /dev/stdin $out/lib/pkgconfig/wasmer.pc
  '';

  env.LLVM_SYS_180_PREFIX = lib.optionalString withLLVM llvmPackages.llvm.dev;

  # Tests are failing due to `Cannot allocate memory` and other reasons
  doCheck = false;

  meta = {
    description = "Universal WebAssembly Runtime C API";
    longDescription = ''
      Wasmer is a standalone WebAssembly runtime for running WebAssembly outside
      of the browser, supporting WASI and Emscripten. Wasmer can be used
      standalone (via the CLI) and embedded in different languages, running in
      x86 and ARM devices.
    '';
    homepage = "https://wasmer.io/";
    license = lib.licenses.mit;
    platforms = with lib.platforms; linux ++ darwin;
    maintainers = with lib.maintainers; [
      Br1ght0ne
      shamilton
      nickcao
    ];
  };
}
