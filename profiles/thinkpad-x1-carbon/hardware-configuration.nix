# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "i2c-dev" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.extraModprobeConfig = ''
    options snd_intel_dspcfg dsp_driver=1
  '';

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/54b6c0e4-9b42-4549-be1d-49d43aff9263";
      fsType = "btrfs";
      options = [ "noatime,space_cache=v2,compress=zstd,ssd,discard=async,subvol=@" ];
    };

  boot.initrd.luks.devices."root".device = "/dev/disk/by-uuid/79869bdd-49a1-44d5-b57c-0ca9fa89c4c9";

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/54b6c0e4-9b42-4549-be1d-49d43aff9263";
      fsType = "btrfs";
      options = [ "noatime,space_cache=v2,compress=zstd,ssd,discard=async,subvol=@home" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/54b6c0e4-9b42-4549-be1d-49d43aff9263";
      fsType = "btrfs";
      options = [ "noatime,space_cache=v2,compress=zstd,ssd,discard=async,subvol=@nix" ];
    };

  fileSystems."/snapshots" =
    { device = "/dev/disk/by-uuid/54b6c0e4-9b42-4549-be1d-49d43aff9263";
      fsType = "btrfs";
      options = [ "noatime,space_cache=v2,compress=zstd,ssd,discard=async,subvol=@snapshots" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/28E0-4664";
      fsType = "vfat";
    };

  swapDevices = [ ];

  # Network
  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s13f0u3u4.useDHCP = lib.mkDefault true;
  # networking.interfaces.wwp0s20f0u8i1.useDHCP = lib.mkDefault true;

  # GPU (Accelerate Video Playback)
  # ref: https://nixos.wiki/wiki/Accelerated_Video_Playback
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # CPU
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Power Management
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  # High-DPI console
  console.font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
}
