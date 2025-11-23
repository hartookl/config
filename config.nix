{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # === БАЗОВАЯ СИСТЕМА ===
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 3;
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # === СЕТЬ И WIFI ===
  networking = {
    hostName = "nixos-hypr";
    networkmanager.enable = true;
  };

  # === ЛОКАЛИЗАЦИЯ И РАСКЛАДКА ===
  time.timeZone = "Asia/Yekaterinburg";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = ["en_US.UTF-8/UTF-8" "ru_RU.UTF-8/UTF-8"];
    extraLocaleSettings = {
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
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  services.xserver = {
    layout = "us,ru";
    xkbOptions = "grp:alt_shift_toggle";
    xkbVariant = "";
  };

  # === ДРАЙВЕРЫ NVIDIA RTX 4070 === 
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.production;
    powerManagement = {
      enable = true;
      finegrained = true;
    };
    nvidiaSettings = true;
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [ 
      nvidia-vaapi-driver 
      vaapiVdpau 
      libvdpau-va-gl 
    ];
    extraPackages32 = with pkgs; [
      driversi686Linux.nvidia-vaapi-driver
    ];
  };

  boot.kernelParams = [
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "nvidia.NVreg_EnableGpuFirmware=1"
    "nvidia-drm.modeset=1"
  ];
  boot.blacklistedKernelModules = [ "nouveau" ];

  # === WAYLAND + HYPRLAND === 
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    nvidiaPatches = true;
  };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # === ЗВУК - PIPEWIRE === 
  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # === ПОЛЬЗОВАТЕЛЬ hartookl ===
  users.users.hartookl = {
    isNormalUser = true;
    description = "hartookl";
    extraGroups = [ 
      "wheel" "networkmanager" "audio" "video" "storage" 
    ];
    initialPassword = "6660";
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # === СИСТЕМНЫЕ ПАКЕТЫ ===
  environment.systemPackages = with pkgs; [
    # Базовые утилиты
    vim wget curl git htop file mc tmux tree
    eza bat fzf bottom duf ripgrep
    
    # Сеть
    networkmanagerapplet
    
    # Терминалы
    kitty alacritty
    
    # Браузеры
    firefox chromium
    
    # Файловые менеджеры
    nautilus thunar
    
    # Мультимедиа
    vlc mpv
    
    # Разработка
    vscode
    python3
    python3Packages.pip
    python3Packages.virtualenv
    python3Packages.numpy
    python3Packages.pandas
    python3Packages.requests
    rustc
    cargo
    rustfmt
    rust-analyzer
    clippy
    
    # Hyprland утилиты
    waybar
    rofi-wayland
    dunst
    swww
    grim
    slurp
    wl-clipboard
    hyprpaper
    
    # NVIDIA утилиты
    nvidia-settings
    glxinfo
    
    # Qt приложения и настройки
    qt5.qtwayland
    qt6.qtwayland
    libsForQt5.qt5ct
    libsForQt5.kdeconnect-kde
  ];

  # === ПЕРЕМЕННЫЕ ОКРУЖЕНИЯ ДЛЯ WAYLAND + NVIDIA + QT === 
  environment.sessionVariables = {
    # NVIDIA Wayland
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    LIBVA_DRIVER_NAME = "nvidia";
    WLR_RENDERER = "vulkan";
    
    # Wayland
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
    
    # Qt настройки
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    
    # Приложения
    MOZ_ENABLE_WAYLAND = "1";
    SDL_VIDEODRIVER = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    
    # Electron/CEF приложения 
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    
    # DPI настройки для 82 DPI
    GDK_SCALE = "1";
    GDK_DPI_SCALE = "1";
  };

  # === СЕРВИСЫ ===
  services = {
    openssh.enable = true;
    blueman.enable = true;
    printing.enable = true;
  };

  # === АППАРАТНОЕ ОБЕСПЕЧЕНИЕ ===
  hardware = {
    enableRedistributableFirmware = true;
    bluetooth.enable = true;
  };

  # === NIX НАСТРОЙКИ ===
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "hartookl" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  system.stateVersion = "23.11";
}
