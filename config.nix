{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # === БАЗОВАЯ СИСТЕМА ===
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # === СЕТЬ И WIFI ===
  networking.hostName = "nixos-hypr";
  networking.networkmanager.enable = true;

  # === ЛОКАЛИЗАЦИЯ И РАСКЛАДКА ===
  time.timeZone = "Asia/Yekaterinburg";
  i18n.defaultLocale = "en_US.UTF-8";

  console.keyMap = "us";

  # === ДРАЙВЕРЫ NVIDIA RTX 4070 === 
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;
  };

  hardware.opengl.enable = true;

  # === WAYLAND + HYPRLAND === 
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
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
    pulse.enable = true;
  };

  # === ПОЛЬЗОВАТЕЛЬ hartookl ===
  users.users.hartookl = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "6660";
  };

  security.sudo.wheelNeedsPassword = false;

  # === СИСТЕМНЫЕ ПАКЕТЫ ===
  environment.systemPackages = with pkgs; [
    vim wget curl git
    networkmanagerapplet
    firefox
    nvidia-settings
  ];

  system.stateVersion = "24.05";  # ← ИСПРАВЛЕНО НА 24.05
}
