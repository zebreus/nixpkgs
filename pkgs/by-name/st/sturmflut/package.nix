{
  stdenv,
  lib,
  pkg-config,
  imagemagick,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "sturmflut";
  version = "0-unstable-2024-06-03";

  src = fetchFromGitHub {
    owner = "zebreus";
    repo = "sturmflut";
    rev = "292bb5b1c5153acc45bfd32f17374e9731cd8ca5";
    hash = "sha256-PCwe7LvuEUXonDZjt+ETa4eFN8xWvHlNIFqz5pEx02w=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ imagemagick ];
  
  installFlags = [ "DESTDIR=$(out)" ];

  meta = with lib; {
    description = "Fast (80+ Gbit/s) pixelflut client with full IPv6 and animation support";
    homepage = "https://github.com/TobleMiner/sturmflut";
    license = licenses.mit;
    maintainers = with maintainers; [ zebreus ];
    platforms = platforms.unix ;
    mainProgram = "sturmflut";
  };
}
