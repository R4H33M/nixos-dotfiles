{ lib
, stdenv
, fetchzip
, makeWrapper
, copyDesktopItems
, steam-run
, makeDesktopItem
}:

stdenv.mkDerivation rec {
  pname = "meikipop";
  version = "2.0.3";

  src = fetchzip {
    # Replace this with the actual release URL!
    url = "https://github.com/rtr46/meikipop/releases/download/v${version}/meikipop.linux.x64.tar.gz";
    hash = "sha256-AZhWIDJmib0H1SJ/Mfc6OkbQM4pwlCf+/a+qyY99itY="; 
  };

  nativeBuildInputs = [ makeWrapper copyDesktopItems ];

  desktopItems = [
    (makeDesktopItem {
      name = "meikipop";
      desktopName = "meikipop";
      exec = "meikipop"; 
      terminal = true;
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/meikipop
    mkdir -p $out/bin

    cp -r * $out/opt/meikipop/
    chmod +x $out/opt/meikipop/meikipop

    makeWrapper ${steam-run}/bin/steam-run $out/bin/meikipop \
      --add-flags "$out/opt/meikipop/meikipop"

    runHook postInstall
  '';
}
