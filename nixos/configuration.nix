{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  time.timeZone = "Europe/Moscow";

  boot = {
    loader = {
      systemd-boot.enable = true;
      timeout = 3;
      efi.canTouchEfiVariables = true;
    };

    kernel.sysctl = { "fs.inotify.max_user_watches" = 100000; };

    extraModprobeConfig = ''
      options iwlwifi fw_monifor=1
    '';

    cleanTmpDir = true;
  };

  powerManagement.enable = true;

  # systemd.services.systemd-udev-settle.enable = false;
  systemd.services.NetworkManager-wait-online.enable = false;

  # hardware.enableAllFirmware = true;
  hardware.bluetooth.enable = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio = {
    enable = true;
    support32Bit = true;
    extraConfig = ''
      # Automatically switch to newly connected devices.
      # load-module module-switch-on-connect

      # Discover Apple iTunes devices on network.
      load-module module-raop-discover
    '';
    zeroconf.discovery.enable = true;

    # Enable extra bluetooth modules, like APT-X codec.
    extraModules = [ pkgs.pulseaudio-modules-bt ];

    # Enable bluetooth (among others) in Pulseaudio
    package = pkgs.pulseaudioFull;
  };
  # Make sure pulseaudio is being used as sound system
  # for the different applications as well.
  nixpkgs.config.pulseaudio = true;

  networking = {
    hostName = "porivaev";

    firewall = {
      enable = false;
      allowedTCPPorts = [
        3000 # Development
        8010 # VLC Chromecast streaming
        8080 # Development
      ];
      allowPing = true;
    };

    networkmanager.enable = true;
  };

  environment.systemPackages = with pkgs; [
    acpi
    bash
    binutils
    bridge-utils
    efibootmgr
    findutils
    hicolor_icon_theme
    htop
    inetutils
    iw
    ntfs3g
    openvpn
    unzip
    neovim
    wget
    wirelesstools
    git
    jq

    docker

    avahi
    networkmanager_openvpn
    usbutils

    nox
    direnv

    slack
    termite
    google-chrome
    nixfmt
    gimp
    tdesktop
    zoom

    rofi
    mako
    mesa
    mesa_drivers
    sway
    grim
    slurp
    waybar
    wl-clipboard
    libnotify
    pavucontrol
    xdg-user-dirs
  ];

  services.acpid.enable = true;
  services.logind.lidSwitch = "suspend";

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="0925", ATTR{idProduct}=="3881", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="21a9", ATTR{idProduct}=="1001", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="2341", ATTR{idProduct}=="0043", MODE="0666", SYMLINK+="arduino"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", MODE="0664", GROUP="uucp"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="2341", ATTRS{idProduct}=="0043", MODE="0660", SYMLINK+="ttyArduinoUno"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", MODE="0660", SYMLINK+="ttyArduinoNano2"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", MODE="0660", SYMLINK+="ttyArduinoNano"
  '';

  services.locate.enable = true;
  services.postgresql.enable = true;

  services.printing = {
    enable = true;
    drivers = [ pkgs.gutenprint pkgs.splix pkgs.cupsBjnp ];
  };

  services.avahi = {
    enable = true;
    browseDomains = [ ];
    publish.enable = false;
  };

  services.redshift = { enable = true; };
  location.provider = "geoclue2";

  services.xserver.displayManager.gdm = {
    enable = true;
    wayland = true;
  };
  programs.sway.enable = true;

  programs.zsh.enable = true;
  programs.bash.enableCompletion = true;
  programs.adb.enable = true;

  virtualisation.docker.enable = true;

  users.defaultUserShell = "/var/run/current-system/sw/bin/zsh";
  users.users.g = {
    uid = 1000;
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "network"
      "uucp"
      "dialout"
      "networkmanager"
      "docker"
      "audio"
      "video"
      "input"
      "sway"
    ];
    useDefaultShell = true;
  };

  nix.trustedUsers = [ "root" "@wheel" ];
  nix.extraOptions = ''
    experimental-features = nix-command
  '';

  nixpkgs.config.allowUnfree = true;

  nix = {
    gc.automatic = true;
    useSandbox = true;
    package = pkgs.nixUnstable;
  };

  system.stateVersion = "20.03";
}
