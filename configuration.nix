{ config, pkgs, ... }:

{
  imports =
    [ ./hardware-configuration.nix ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hostname
  networking.hostName = "nixos";

  # Networking (WiFi + LAN)
  networking.networkmanager.enable = true;

  # Time & locale
  time.timeZone = "Asia/Jakarta";
  i18n.defaultLocale = "en_US.UTF-8";

  # X11 + KDE Plasma
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Printing
  services.printing.enable = true;

  # Audio (PipeWire)
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Power management
  powerManagement.enable = true;
  services.power-profiles-daemon.enable = true;

  # AppImage support
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  # User
  users.users.dayy = {
    isNormalUser = true;
    description = "Dayy";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  # Allow unfree (needed for Brave & fonts)
  nixpkgs.config.allowUnfree = true;

  #Steam
  programs.steam.enable = true;

  #Flatpak
  services.flatpak.enable = true;

  # Browser
  programs.firefox.enable = false;

  # MariaDB
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
  };

  # Fonts (Times New Roman)
  fonts.packages = with pkgs; [
    corefonts
    jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
  ];
/*
  #waydroid
  virtualisation.waydroid.enable = true;

  # Recommended for modern kernels (iptables/nft compatibility)
  virtualisation.waydroid.package = pkgs.waydroid-nftables;

   # Ensure services are enabled properly
   systemd.services.waydroid-container.wantedBy = [ "multi-user.target" ];*/

  # System packages
  environment.systemPackages = with pkgs; [
   # Global Python environment wrapped with your required libraries
    (python3.withPackages (ps: with ps; [
      python-dotenv
      anthropic
      playwright
      pip # Replaces global standalone pip safely inside the wrapper
    ]))

    # Playwright's system browser binaries
    playwright-driver.browsers

   # Browser
    brave

    # Basic tools
    fastfetch
    git
    wget
    curl
    unzip
    p7zip
    gamemode
    mangohud
    cmatrix
    spotify
    ani-cli
    wl-clipboard
    libreoffice

    # PHP + Laravel
    php
    phpPackages.composer

    # Node.js (React)
    nodejs_20
    nodePackages.npm
    nodePackages.yarn

    # Python
    python3
    python3Packages.pip

    # Java
    jdk

    # C++
    gcc
    gnumake
    cmake

    # Editor
    antigravity
  ];

 # Global Environment Variables
  environment.variables.PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";

  # Firewall
  networking.firewall.enable = true;

  system.stateVersion = "25.11";
}
