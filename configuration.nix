# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix # Use absolute path so you use automatically generated version
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.device = "nodev";

  boot.loader.grub.theme = pkgs.stdenv.mkDerivation {
    pname = "fallout-grub-theme";
    version = "3.1";
    src = pkgs.fetchFromGitHub {
      owner = "shvchk";
      repo = "fallout-grub-theme";
      rev = "2c51d28";
      hash = "sha256-iQU1Rv7Q0BFdsIX9c7mxDhhYaWemuaNRYs+sR1DF0Rc=";
    };
    installPhase = "cp -r . $out";
  };

  # Old Systemd boot
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;

  # Enable debugfs for iwlwifi
  boot.kernelPatches = [ {
    name = "iwlwifi-config";
    patch = null;
    structuredExtraConfig = {
      IWLWIFI_DEBUGFS = lib.kernel.yes;
    };
  } ];

  # G16 specific
  boot.kernelParams = [
    "i915.enable_dpcd_backlight=1" 
    "nvidia.NVreg_EnableBacklightHandler=0"
    "nvidia.NVreg_RegistryDwords=EnableBrightnessControl=0"
  ];
  
  # G16 specific
  boot.initrd.prepend = [ "${import ./gu605c-spi-cs-gpio { inherit pkgs; }}/asus-gu605c-acpi.cpio" ];

  # G16 specific - ensure no integrated GPU stuff
  boot.extraModprobeConfig = ''
    blacklist nouveau
    options nouveau modeset=0
  '';

  # G16 specific
  services.asusd.enable = true;
  services.asusd.enableUserService = true;
  
  services.udev.extraRules = ''
  # Remove NVIDIA USB xHCI Host Controller devices, if present
  ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"
  # Remove NVIDIA USB Type-C UCSI devices, if present
  ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"
  # Remove NVIDIA Audio devices, if present
  ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"
  # Remove NVIDIA VGA/3D controller devices
  ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
  # Allow brightness to be changed without root
  ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"
  '';

  boot.blacklistedKernelModules = [ "nouveau" "nvidia" "nvidia_drm" "nvidia_modeset" ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Prevent trackpad from moving while typing
  services.libinput.touchpad.disableWhileTyping = true;

  networking.hostName = "cennestre"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver = {
    enable = true;
    windowManager.qtile.enable = true;
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
    options = "caps:numlock"; #somethings weird with this that is persisting
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    ipafont
    kochi-substitute
    noto-fonts-cjk-sans
  ];

  services.printing.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [ 
      # fcitx5-mozc
      fcitx5-mozc-ut
      fcitx5-gtk 
    ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.xygzy = {
    isNormalUser = true;
    description = "xygzy";
    extraGroups = [ "networkmanager" "wheel" "dialout" ];
    packages = with pkgs; [

      # Core
      (chromium.override { enableWideVine = true; })
      kitty
      git
      networkmanagerapplet
      blueman
      flameshot
      obsidian
      rofi
      rofimoji
      mate.caja

      # Core Tools
      unzip

      # Communication
      signal-desktop
      
      # Developer Stuff
      pyright
      clang
      clang-tools
      starship
      fzf
      (vscode-with-extensions.override {
        vscodeExtensions = with vscode-extensions; [
          james-yu.latex-workshop
        ];
      })

      # Language learning
      anki-bin
      mpv

      # Hacking
      qFlipper
      wireshark

      # Misc
      texliveFull
    ];
  };

  programs.starship.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  hardware.flipperzero.enable = true; # since we are doing a user install?

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
