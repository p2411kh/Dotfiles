{ config, pkgs, ... }:

let
  qylockSrc = pkgs.fetchFromGitHub {
    owner = "Darkkal44";
    repo = "qylock";
    rev = "main";
    sha256 = "sha256-AYoc6yEcp+yeud+GKkg5X8BKKSMq0ogEDuB4g+hosfs=";
  };

  winterTheme = pkgs.stdenv.mkDerivation {
    pname = "sddm-theme-winter";
    version = "1.0";
    src = qylockSrc;
    installPhase = ''
      mkdir -p $out/share/sddm/themes
      cp -r themes/winter $out/share/sddm/themes/winter
    '';
  };
in
{
  imports = [ ./hardware-configuration.nix ];

  # Загрузчик
  boot.loader = {
    efi.canTouchEfiVariables = true;
    limine = {
      enable = true;
      extraEntries = ''
        /Windows
            protocol: efi
            path: boot():/EFI/Microsoft/Boot/bootmgfw.efi
            comment: Boot Windows
      '';
    };
  };

  # Plymouth (заставка)
  boot.plymouth.enable = true;
  boot.plymouth.theme = "breeze";
  boot.kernelParams = [ "quiet" "splash" ];

  # Сеть
  networking.hostName = "user-nixos";
  networking.networkmanager.enable = true;

  # Часовой пояс
  time.timeZone = "Europe/Vienna";

  # Локализация (русский язык)
  i18n.defaultLocale = "ru_RU.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

  # Консоль
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # X11
  services.xserver.enable = true;
  services.xserver.xkb.layout = "us,ru";
  services.xserver.xkb.options = "grp:alt_shift_toggle";

  # SDDM
  services.displayManager.sddm = {
    enable = true;
    package = pkgs.kdePackages.sddm;   # обязательно Qt6-версия для QML-тем
    wayland.enable = true;
    theme = "winter";
    extraPackages = with pkgs.kdePackages; [ qt5compat qtsvg qtmultimedia ];
  };

  # Hyprland
  programs.hyprland.enable = true;

  # Звук (PipeWire)
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };

  # Дополнительные сервисы
  services.printing.enable = true;
  services.libinput.enable = true;

  # Разрешить unfree пакеты (нужно для некоторых программ)
  nixpkgs.config.allowUnfree = true;

  services.flatpak.enable = true;
  programs.fish.enable = true;

  users.users.p2411kh = {
    shell = pkgs.fish;
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    packages = with pkgs; [
      firefox
    ];
  };

  # Sudo без пароля
  security.sudo.extraRules = [
    {
      groups = [ "wheel" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Системные пакеты (оба списка объединены в один)
  environment.systemPackages = with pkgs; [
    winterTheme
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly

    nano
    bibata-cursors
    git
    grim
    kdePackages.dolphin
    htop
    wget
    fish
    kitty
    firefox
    vim
    fastfetch
    cava
    steam
    steam-run
    flatpak
    discord
    telegram-desktop
    pywal
    lsd
    bat
    zoxide
    lazygit
    neovim
    tldr
    btop
    cmatrix
    #obs-studio
    #obs-studio-plugins.obs-vkcapture
    #krita
    #blender
    wofi
    waybar
    awww
    #nwg-look
    #libsForQt5.qt5ct
    #qt6Packages.qt6ct
    gcc
    gnumake
    noctalia
  ];

  # Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Версия
  system.stateVersion = "26.05";
}
