{ lib
, stdenv
, fetchFromGitHub
}:
stdenv.mkDerivation {
  pname = "sddm-xdm-theme";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "zebreus";
    repo = "sddm-xdm-theme";
    rev = "893555e9d9b005faf4cf29de30ab151813638077";
    sha256 = "sha256-PGa/BK5MyCKFh413qhM1DFbe5cCmUpDrHw8C2cMWJyo=";
  };

  postInstall = ''
    mkdir -p $out/share/sddm/themes/xdm

    mv theme.conf *.qml *.png $out/share/sddm/themes/xdm
  '';

  meta = with lib; {
    license = licenses.gpl3;
    maintainers = with lib.maintainers; [ zebreus ];
    homepage = "https://github.com/zebreus/sddm-xdm-theme";
    description = "A sddm theme that looks like xdm";
  };
}
