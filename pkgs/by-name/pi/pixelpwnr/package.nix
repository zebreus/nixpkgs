{
  lib,
  rustPlatform,
  fetchFromGitHub,
  unstableGitUpdater,
}:

rustPlatform.buildRustPackage {
  pname = "pixelpwnr";
  version = "0-unstable-2023-12-30";

  src = fetchFromGitHub {
    owner = "timvisee";
    repo = "pixelpwnr";
    rev = "38ce0f0c43b5072e35c19048dbe12301614f25ca";
    hash = "sha256-feSrwo8ey9+/gU12QmuBLlqGeWXK23ouZkVYzGPli2E=";
  };

  cargoHash = "sha256-zT8l6eQNB+dWSpNVPvQYrwqfaszpPy6cy68kizkzQFo=";

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Insanely fast pixelflut client for images and animations written in Rust";
    homepage = "https://github.com/timvisee/pixelpwnr";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ zebreus ];
    mainProgram = "pixelpwnr";
  };
}
