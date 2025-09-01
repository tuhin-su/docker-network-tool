{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

    nix = {
    settings = {
      auto-optimise-store = true;

      # Enable new-style CLI
      experimental-features = [
        "nix-command"
        "flakes"
        "ca-derivations"
      ];

      # Optional: improves binary cache speed
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7w5JFrY2r0t6B3Q9S2P3Hs="
      ];
    };
  };


  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;
  boot.kernelModules = [ 
    "kvm"
    "kvm_amd"
    "vfio"
    "vfio_iommu_type1"
    "vfio_pci"
  ];

  boot = {
    # Enable "Silent boot"
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
 };
 hardware.graphics.enable = true;


  virtualisation.docker.enable = true;

  environment.etc.hosts = lib.mkForce {
    source = "/etc/hosts.pord";
    mode = "0644";
    user = "<user_name>";
    group = "root";
  };




  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  
  networking = {
    networkmanager.wifi.macAddress = "random";
    networkmanager.ethernet.macAddress = "random";

    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
      rejectPackets = true;
    };
  };

  programs.wireshark = {
    enable = true;
    dumpcap.enable = true;
    usbmon.enable = true;
  };

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_IN";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the Deepin Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.deepin.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.<user_name> = {
    isNormalUser = true;
    description = "<user_name>";
    extraGroups = [ "networkmanager" "docker" "wheel" "wireshark" ];
    shell = pkgs.zsh;
    packages = with pkgs; [];
  };
  
  
  # Install firefox.
  programs.firefox.enable = true;
  programs.zsh.enable = true;
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [

    # docker-up
  (writeShellScriptBin "docker-up" ''
    #!/usr/bin/env bash
    sudo bash -c /etc/nixos/scripts/docker-up
  '')

  # docker-down
  (writeShellScriptBin "docker-down" ''
    #!/usr/bin/env bash
    sudo bash -c /etc/nixos/scripts/docker-down
  '')

  # docker-sync
  (writeShellScriptBin "docker-sync" ''
    #!/usr/bin/env bash
      sudo bash -c /etc/nixos/scripts/docker-sync
  '')

     wget
     google-chrome
     vscode
     nmap
     macchanger
     cudaPackages.cudatoolkit
     cudaPackages.cudnn
     wireshark-qt
     gcc
     clang
     python3
     openjdk
     git
     htop
     curl
     wget
     tmux
     jq
     unzip
     zip
     gnumake
     cmake
     tree
     inetutils
     iproute2
     docker
     docker-compose
     glibc
     libGL
     qemu_kvm
     qemu
     gnutar
     gzip
     xz
  ];

  services = {
    avahi.enable = false;
  };

  # docker-sync service
  systemd.services.docker-sync = {
    description = "Docker Resolver Sync Service";
    serviceConfig = {
      Type = "simple";
      ExecStart = "/run/current-system/sw/bin/docker-sync";
      Restart = "no";
    };
    # Do NOT start at boot; controlled by scripts
    wantedBy = [];
  };


  services.udev = {
    extraRules = ''
      SUBSYSTEM=="usbmon", GROUP="wireshark", MODE="0640"
    '';
  };  
  system.stateVersion = "25.05";
}
