{ lib
, buildGoModule
, fetchFromGitHub
, installShellFiles
}:

buildGoModule rec {
  pname = "doggo";
  version = "0.5.5";

  src = fetchFromGitHub {
    owner = "mr-karan";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-qc6RYz2bVaY/IBGIXUYO6wyh7iUDAJ1ASCK0dFwZo6s=";
  };

  vendorHash = "sha256-UhSdYpK54c4+BAP/d/zU91LIBE05joOLHoV1XkNMYNw=";
  nativeBuildInputs = [ installShellFiles ];
  subPackages = [ "cmd/doggo" ];

  ldflags = [
    "-w -s"
    "-X main.buildVersion=v${version}"
  ];

  postInstall = ''
    installShellCompletion --cmd doggo \
      --fish --name doggo.fish completions/doggo.fish \
      --zsh --name _doggo completions/doggo.zsh
  '';

  meta = with lib; {
    homepage = "https://github.com/mr-karan/doggo";
    description = "Command-line DNS Client for Humans. Written in Golang";
    longDescription = ''
      doggo is a modern command-line DNS client (like dig) written in Golang.
      It outputs information in a neat concise manner and supports protocols like DoH, DoT, DoQ, and DNSCrypt as well
    '';
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ georgesalkhouri ];
  };
}
