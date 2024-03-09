# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, pkgs-unstable, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    # Use the systemd-boot EFI boot loader.
    kernelPackages = pkgs-unstable.linuxPackages_testing;
    # kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = [ "ext4" "btrfs" "xfs" "fat" "vfat" "cifs" "nfs" ];

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd = {
      availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" "lz4" ];
      kernelModules = [ "i2c-dev" ];
      luks.devices."root" = {
        device = "/dev/disk/by-uuid/6cf8230d-0ddf-44b2-9be0-c24ce47072e3";
        # the keyfile(or device partition) that should be used as the decryption key for the encrypted device.
        # if not specified, you will be prompted for a passphrase instead.
        #keyFile = "/root-part.key";

        # whether to allow TRIM requests to the underlying device.
        # it's less secure, but faster.
        allowDiscards = true;
        # Whether to bypass dm-crypt’s internal read and write workqueues.
        # Enabling this should improve performance on SSDs;
        # https://wiki.archlinux.org/index.php/Dm-crypt/Specialties#Disable_workqueue_for_increased_solid_state_drive_(SSD)_performance
        bypassWorkqueues = true;
      };
    };

    kernelModules = [ "kvm-intel" ];
    kernelParams = [ ];
    extraModulePackages = [ ];
    extraModprobeConfig = ''
      options snd_hda_intel power_save=1 power_save_controller=Y
      options i915 enable_guc=1 enable_fbc=1 enable_psr=1 force_probe=5690
    '';
    # clear /tmp on boot to get a stateless /tmp directory.
    tmp.cleanOnBoot = true;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/9976cd06-8015-483b-b300-340426135689";
      fsType = "btrfs";
      options = [ "noatime" "space_cache=v2" "compress=zstd" "ssd" "discard=async" "subvol=@" ];
    };

    "/home" =
      {
        device = "/dev/disk/by-uuid/9976cd06-8015-483b-b300-340426135689";
        fsType = "btrfs";
        options = [ "noatime" "space_cache=v2" "compress=zstd" "ssd" "discard=async" "subvol=@home" ];
      };

    "/nix" =
      {
        device = "/dev/disk/by-uuid/9976cd06-8015-483b-b300-340426135689";
        fsType = "btrfs";
        options = [ "noatime" "space_cache=v2" "compress=zstd" "ssd" "discard=async" "subvol=@nix" ];
      };

    "/snapshots" =
      {
        device = "/dev/disk/by-uuid/9976cd06-8015-483b-b300-340426135689";
        fsType = "btrfs";
        options = [ "noatime" "space_cache=v2" "compress=zstd" "ssd" "discard=async" "subvol=@snapshots" ];
      };

    "/boot" =
      {
        device = "/dev/disk/by-uuid/A323-8AC7";
        fsType = "vfat";
      };
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

  hardware = {
    # linux-firmware
    enableAllFirmware = true;

    # GPU
    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver # Intel Media Driver for VAAPI
        intel-vaapi-driver # VAAPI user mode driver for Intel Gen Graphics family
        # vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
        vaapiVdpau # VDPAU driver for the VAAPI library
        libvdpau-va-gl # VDPAU driver with OpenGL/VAAPI backend
      ];
    };

    # CPU
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };

  # High-DPI console
  console.font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
}
