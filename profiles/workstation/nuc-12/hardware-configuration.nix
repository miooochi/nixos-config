# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ inputs, config, lib, pkgs, pkgs-small, modulesPath, system, ... }:

# References:
# https://nixos.wiki/wiki/Intel_Graphics
{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    # Use the systemd-boot EFI boot loader.
    kernelPackages = inputs.chaotic.packages.${system}.linuxPackages_cachyos;
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

    tmp = {
      # Clear /tmp on boot to get a stateless /tmp directory.
      cleanOnBoot = true;
      # Size of tmpfs in percentage.
      tmpfsSize = "5%"; # default "50%"
    };
  };

  fileSystems = {
    "/" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [ "relatime" "size=25%" "mode=755" ];
    };

    "/nix" =
      {
        device = "/dev/disk/by-uuid/9976cd06-8015-483b-b300-340426135689";
        fsType = "btrfs";
        options = [ "noatime" "space_cache=v2" "compress-force=zstd" "ssd" "discard=async" "subvol=@nix" ];
      };

    "/persistent" =
      {
        device = "/dev/disk/by-uuid/9976cd06-8015-483b-b300-340426135689";
        fsType = "btrfs";
        options = [ "noatime" "space_cache=v2" "compress-force=zstd" "ssd" "discard=async" "subvol=@persistent" ];
        # impermanence's data is required for booting
        neededForBoot = true;
      };

    "/snapshots" =
      {
        device = "/dev/disk/by-uuid/9976cd06-8015-483b-b300-340426135689";
        fsType = "btrfs";
        options = [ "noatime" "space_cache=v2" "compress-force=zstd" "ssd" "discard=async" "subvol=@snapshots" ];
      };

    "/boot" =
      {
        device = "/dev/disk/by-uuid/5983-F041";
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

  # GPU (Accelerate Video Playback)
  # ref: https://nixos.wiki/wiki/Accelerated_Video_Playback
  nixpkgs.config.packageOverrides = pkgs-small: {
    vaapiIntel = pkgs-small.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware = {
    # linux-firmware
    enableAllFirmware = true;

    # GPU (OpenGL)
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs-small; [
        intel-compute-runtime # Intel Graphics Compute Runtime for OpenCL. Replaces Beignet for Gen8 (Broadwell) and beyond
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

  # Mesa
  chaotic.mesa-git.enable = true;

  # High-DPI console
  console.font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";

  nixpkgs.hostPlatform = lib.mkDefault system;
}
