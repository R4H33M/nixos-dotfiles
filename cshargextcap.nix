{
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "cshargextcap";
  version = "unstable-main";

  src = fetchFromGitHub {
    owner = "siemens";
    repo = "cshargextcap";
    rev = "main";
    hash = "sha256-LTmhr5Mi6aopgRBcEOCiDNUcKh1pfpX5HjEY/kEls+A="; 
  };

  # 2. After fixing the source hash above, run build again. 
  # Replace this with the actual vendorHash provided in the error message.
  vendorHash = "sha256-IXPhqwm/zXsJT8EmbuqF7+OwzflfTZ/PsXW8Jnl78+E=";

  # Based on PKGBUILD: Build the command specifically
  subPackages = [ "cmd/cshargextcap" ];

  # Based on PKGBUILD: Tags and Flags
  tags = [ "netgo" "osusergo" ];
  ldflags = [
    "-s" "-w" # Strip debug symbols for smaller binary
  ];

  postInstall = ''
    # Create the extcap directory structure within this package 
    # (useful if you want to use this package standalone or via symlink)
    mkdir -p $out/lib/wireshark/extcap
    ln -s $out/bin/cshargextcap $out/lib/wireshark/extcap/cshargextcap

    # Install the Desktop file (as done in the Arch PKGBUILD)
    # install -Dm644 packaging/linux/com.github.siemens.packetflix.desktop \
      # $out/share/applications/com.github.siemens.packetflix.desktop
  '';
}
