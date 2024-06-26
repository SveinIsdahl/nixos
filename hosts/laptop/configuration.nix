{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
	
  nix.settings.experimental-features = [ "nix-command" ];

  networking.networkmanager.enable = true;
  virtualisation.docker.enable = true;
  # Set your time zone.
  time.timeZone = "Europe/Oslo";
  # Locale
  i18n.defaultLocale = "en_US.UTF-8";

  boot.extraModprobeConfig = ''
  blacklist nouveau
  options nouveau modeset=0
	'';
  
  services.udev.extraRules = ''
    # Remove NVIDIA USB xHCI Host Controller devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"
    # Remove NVIDIA USB Type-C UCSI devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"
    # Remove NVIDIA Audio devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"
    # Remove NVIDIA VGA/3D controller devices
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
  '';
  boot.blacklistedKernelModules = [ "nouveau" "nvidia" "nvidia_drm" "nvidia_modeset" ];

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  environment.gnome.excludePackages = (with pkgs; [
    gnome-tour
  ]) ++ (with pkgs.gnome; [
    gnome-music
    gnome-weather
    gnome-calendar
    gnome-clocks
    gnome-contacts
    epiphany
    geary
    tali
    iagno
    hitori
    atomix
  ]);
  #programs.dconf.enable = true; TODO: Enable

  services.xserver = {
    layout = "no";
    xkbVariant = "";
    excludePackages = [
     pkgs.xterm
    ];
  };
  console.keyMap = "no";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    #media-session.enable = true;
  };

  users.users.svein = {
    isNormalUser = true;
    description = "svein";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };


  #Firefox
  programs.firefox.enable = true;
  programs.firefox.policies = {
    DisableTelemetry = true;
    DisableFirefoxStudies = true;
    DisablePocket = true;
    DisableFirefoxAccounts = true;
    DisableAccounts = true;	
    ExtensionSettings = {
      #"*".installation_mode = "blocked"; # blocks all addons except the ones specified below
      # uBlock Origin:
      "uBlock0@raymondhill.net" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
        installation_mode = "force_installed";
      };
      "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/file/4263752/bitwarden_password_manager-2024.4.1.xpi";
        installation_mode = "force_installed";
      };
      "addon@darkreader.org" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/file/4278339/darkreader-4.9.84.xpi";
        installation_mode = "force_installed";
      };
    };
  };

  programs.git.enable = true; #TODO add config
  nixpkgs.config.allowUnfree = true;
	
  environment.systemPackages = (with pkgs; [
    vscode
    gnomeExtensions.pop-shell #TODO: config this
    htop
    libgcc
    gcc13
    pciutils
    usbutils
    libsmbios
    zip
    spotify
    nmap
    pkgs.man-pages 
    pkgs.man-pages-posix
	clang-tools #Double check if needed
  ]);


  #This should be structured better, but here it stays for now, with hardcoded paths
  system.activationScripts.bashrc = {
    text = ''
      mkdir -p /home/svein
      cat > /home/svein/.bashrc <<EOF
      #!/bin/sh
      alias vim='nvim'
      alias untargz='tar -xvzf'

      export HISTFILESIZE=100000
      export HISTSIZE=100000
      EOF
      chown svein /home/svein/.bashrc
    '';
    deps = [];
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    configure = {
    customRC = ''
        set number relativenumber
		set autoindent noexpandtab tabstop=4 shiftwidth=4
      '';
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [ 
	  	  nvim-treesitter 
          nvim-treesitter.withAllGrammars
	];
      };
    };
  };

  # Systemd service to pull the latest Ubuntu image
  systemd.services.docker-pull-ubuntu = {
    wantedBy = [ "multi-user.target" ];
    after = [ "docker.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.docker}/bin/docker pull ubuntu:latest";
      RemainAfterExit = true;
    };
  };

  system.stateVersion = "24.05";
}
