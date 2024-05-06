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

  # Set your time zone.
  time.timeZone = "Europe/Oslo";
  # Locale
  i18n.defaultLocale = "en_US.UTF-8";

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
    extraGroups = [ "networkmanager" "wheel" ];
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

  programs.neovim.enable = true;
  programs.git.enable = true; #TODO add config
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
	
  environment.systemPackages = (with pkgs; [
    vscode
    gnomeExtensions.pop-shell #TODO: config this
    htop
    libgcc
  ]);
  system.stateVersion = "23.11";
}
