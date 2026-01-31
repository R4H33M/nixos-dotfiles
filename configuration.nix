# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  # Add the local background.png to the Nix store
  greeter_wallpaper = pkgs.runCommand "greeter_wallpaper" { } ''
    cp ${./greeter_wallpaper.png} $out
  '';
  
  # This is manually copied into my home directory for the plugin
  cshargextcap = pkgs.callPackage ./cshargextcap.nix { };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix # Use absolute path so you use automatically generated version
    ];
  
  # Needed for python dynamic libraries
  # Use export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH
  programs.nix-ld.enable = true;

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
  # boot.kernelPatches = [ {
  #   name = "iwlwifi-config";
  #   patch = null;
  #   structuredExtraConfig = {
  #     IWLWIFI_DEBUGFS = lib.kernel.yes;
  #   };
  # } ];

  # G16 specific
  boot.kernelParams = [
    "i915.enable_dpcd_backlight=1" 
    "nvidia.NVreg_EnableBacklightHandler=0"
    "nvidia.NVreg_RegistryDwords=EnableBrightnessControl=0"
    "nvme_core.default_ps_max_latency_us=0"
  ];
  
  # G16 specific
  boot.initrd.prepend = [ "${import ./gu605c-spi-cs-gpio { inherit pkgs; }}/asus-gu605c-acpi.cpio" ];

  # G16 specific - ensure no discrete GPU stuff
  boot.extraModprobeConfig = ''
    blacklist nouveau
    options nouveau modeset=0
  '';

  services.xserver.videoDrivers = [ "modesetting" ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      # Required for modern Intel GPUs (Xe iGPU and ARC)
      intel-media-driver     # VA-API (iHD) userspace
      vpl-gpu-rt             # oneVPL (QSV) runtime

      # Optional (compute / tooling):
      intel-compute-runtime  # OpenCL (NEO) + Level Zero for Arc/Xe
      # NOTE: 'intel-ocl' also exists as a legacy package; not recommended for Arc/Xe.
      # libvdpau-va-gl       # Only if you must run VDPAU-only apps
    ];
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";     # Prefer the modern iHD backend
    # VDPAU_DRIVER = "va_gl";      # Only if using libvdpau-va-gl
  };

  # G16 specific
  services.asusd.enable = true;
  services.asusd.enableUserService = true;
  services.supergfxd.enable = false;
  
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
  ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+rw /sys/class/backlight/%k/brightness"
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
  networking.useNetworkd = true;
  networking.dhcpcd.enable = false;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = [ "gtk" ];
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "root" "xygzy" ];

  # Set your time zone.
  time.timeZone = lib.mkDefault "America/New_York";

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

  services.gnome.gnome-keyring.enable = true;

  programs.sway.enable = true;
  services.displayManager.ly.enable = true;
  services.displayManager.ly.settings = {
    animation = "matrix";
    clear_password = "true";
    default_input = "password";
    brightness_up_cmd = "${pkgs.brightnessctl}/bin/brightnessctl -q -n s +10%";
    brightness_down_cmd = "${pkgs.brightnessctl}/bin/brightnessctl -q -n s 10%-";
  };

  services.journald.extraConfig = "SystemMaxUse=1G";
  services.dbus.implementation = "broker";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
    options = "caps:numlock,lv3:ralt_switch"; #somethings weird with this that is persisting
    extraLayouts.us-no= {
      description = "US layout with Custom Norwegian Shortcuts";
      languages = [ "eng" ];
      symbolsFile = pkgs.writeText "us-no" ''
        xkb_symbols "us-no" {
          include "us(basic)"

          name[Group1]= "US layout with Custom Norwegian Shortcuts";

          // Syntax: [ Level1, Level2, Level3, Level4 ]
          // Level1: Normal
          // Level2: Shift
          // Level3: AltGr (Your existing switch)
          // Level4: AltGr + Shift

          // Map AltGr+A to å / Å
          key <AC01> { [	   a,          A,        aring,           Aring] };

          // Map AltGr+O to ø / Ø
          key <AD09> { [         o,          O,        oslash,          Ooblique] };

          // Map AltGr+E to æ / Æ
          key <AD03> { [	   e,          E,        ae,           AE] };
          
          include "level3(ralt_switch)"
        };
      '';
    };
  };

  # services.xserver.displayManager.lightdm = {
  #   enable = true;
  #   background = greeter_wallpaper;
  #   greeters.slick.enable = true;
  # };

  programs.dconf.enable = true;
  
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

  virtualisation.docker = {
    # Consider disabling the system wide Docker daemon
    enable = false;
    rootless = {
      enable = true;
      setSocketVariable = true;
      daemon.settings = {
        dns = [ "1.1.1.1" "8.8.8.8" ];
      };
    };
  };

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
    extraGroups = [ "networkmanager" "wheel" "dialout" "wireshark"];
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
      xclip # for neovim clipboard support
      xorg.xauth
      betterlockscreen
      starship
      wget
      xdotool # for norwregian key shortcuts

      # Core Tools
      unzip
      file

      # Communication
      signal-desktop
      
      # Developer Stuff
      pyright
      clang
      clang-tools
      fzf
      (vscode-with-extensions.override {
        vscodeExtensions = with vscode-extensions; [
          james-yu.latex-workshop
        ];
      })
      uv
      opam # for COS 320 compilers

      # Language learning
      anki-bin
      mpv

      # Hacking
      qFlipper
      burpsuite
      nmap
      ghidra-bin
      checksec
      binwalk
      hashcat
      # Use Frida as a uv package instead
      # frida-tools
      # This is 2025.10.20
      (builtins.getFlake "github:pwndbg/pwndbg/0af61b512c43b13b9c962b1ad5a380f38df4b9aa").packages.${builtins.currentSystem}.default
      android-tools
      apktool
      jadx
      apksigner
      sage

      # Misc
      texliveFull
      htop
      rubyPackages.github-pages
    ];
  };

  programs.starship.enable = true;


  programs.wireshark.enable = true; 
  programs.wireshark.package = pkgs.wireshark;

  # Flipper stuff
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  hardware.flipperzero.enable = true; # since we are doing a user install?

  programs.zoxide.enable = true;

  # didn't quite work for some reason
  # services.automatic-timezoned.enable = true;

  # Doesn't do anything anymore because of the initExtra
  # programs.zoxide.flags = [
  #   "--cmd cd"
  # ];
  programs.zoxide.enableBashIntegration = false;

  programs.bash = {
    interactiveShellInit = lib.mkOrder 2000
    ''
      eval "$(${lib.getExe pkgs.zoxide} init bash --cmd cd)"    
    '';
  };

  services.tailscale.enable = true;
  
  # for betterlockscreen 
  programs.i3lock.enable = true;
  security.pam.services.i3lock = {};
  programs.xss-lock.enable = true;
  programs.xss-lock.lockerCommand = "${pkgs.betterlockscreen}/bin/betterlockscreen -l dim";

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
