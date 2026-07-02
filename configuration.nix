{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

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

  # Appimage Configuration (FIXED OVERRIDE)
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;
  programs.appimage.package = pkgs.appimage-run.override {
    extraPkgs = pkgs: [ pkgs.icu ];
  };

  # User Configuration
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

  # Steam
  programs.steam = {
  enable = true;
  remotePlay.openFirewall = true;
  dedicatedServer.openFirewall = true;
};

# Fix for unpatched game binaries (Minecraft Font & Graphic Link Errors)
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    xorg.libX11
    xorg.libXext
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXxf86vm
    xorg.libXrender
    xorg.libXtst
    xorg.libXi
    libGL
    libpulseaudio
    alsa-lib
    flite
    freetype     # <-- Added to fix libfreetype.so.6 missing error
    fontconfig   # <-- Added to prevent fallback font rendering crashes
  ];

  # Enable GameMode optimization daemon
  programs.gamemode.enable = true;

  # Flatpak
  services.flatpak.enable = true;

  # Browser
  programs.firefox.enable = false;

  # MariaDB
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
  };

  # Fonts
  fonts.packages = with pkgs; [
    corefonts
    jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
  ];

  # System Packages (Merged and clean)
  environment.systemPackages = with pkgs; [
    # This ensures your overridden appimage-run is actually used by the system!
    config.programs.appimage.package
    kdePackages.partitionmanager

    # Global Python environment wrapped with your required libraries
    (python3.withPackages (ps: with ps; [
      python-dotenv
      anthropic
      playwright
      pip
    ]))

    #Ani-cli
    (ani-cli.overrideAttrs (oldAttrs: {
      version = "master";
      src = pkgs.fetchFromGitHub {
      owner = "pystardust";
      repo = "ani-cli";
      rev = "master";
      sha256 = "sha256-+fR46bWXJ58LkXFvWAO/LyCd5THi7oMcqmhRoCKBZfM=";
    };
  }))

    # Playwright's system browser binaries
    playwright-driver.browsers

    # Browsers & Apps
    brave
    spotify
    chromium

    # BurpSuite
    burpsuite
    cacert

    # Basic tools
    fastfetch
    git
    wget
    curl
    unzip
    unrar
    p7zip
    gamemode
    mangohud
    cmatrix
    wl-clipboard
    libreoffice
    pciutils
    mpv
    openssl
    btop
    smartmontools
    qbittorrent

    # Wine
    wineWowPackages.stable
    winetricks

    # PHP + Laravel
    php
    phpPackages.composer

    # Node.js (React)
    nodejs_20
    nodePackages.npm
    nodePackages.yarn

    # Python (Fallback package)
    python3
    python3Packages.pip

    # Languages / Compilers
    jdk
    gcc
    gnumake
    cmake

    # Editor
    antigravity

  # Custom Legacy Launcher installation (Robust Window Environment Patch)
    (stdenv.mkDerivation rec {
      pname = "legacy-launcher";
      version = "1.24";

      src = fetchurl {
        url = "https://llaun.ch/jar";
        sha256 = "sha256-Cbp1F8ipsweA/5pt4jC4kFJHg1rg2pFNZpkeKztLbE4=";
      };

      dontUnpack = true;

      nativeBuildInputs = [ makeWrapper ];

      # Using standard openjdk/jre with native UI support rather than headless
      buildInputs = [ jdk ];

      installPhase = ''
        mkdir -p $out/share/java $out/bin
        cp $src $out/share/java/LegacyLauncher.jar

        # Build execution wrapper with runtime paths mapped clearly
        makeWrapper ${jdk}/bin/java $out/bin/legacy-launcher \
          --add-flags "-jar $out/share/java/LegacyLauncher.jar" \
          --set AZURE_CLIENT_ID ""

        # Create a compliant desktop entry
        mkdir -p $out/share/applications
        cat > $out/share/applications/legacy-launcher.desktop <<EOF
        [Desktop Entry]
        Name=Legacy Launcher
        Comment=A lightweight Minecraft Launcher
        Exec=$out/bin/legacy-launcher
        Icon=minecraft
        Terminal=false
        Type=Application
        Categories=Game;
        EOF
      '';
    })
  ];

  #Kde Partition Manager
  security.polkit.enable = true;

  # Global Environment Variables
  environment.variables.PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";

  # Firewall
  networking.firewall.enable = true;

  system.stateVersion = "25.11";
}
