# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/profiles/qemu-guest.nix") ];



  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = [ "ext4" "btrfs" "xfs" "fat" "vfat" "cifs" "nfs" ];
    # after resize the disk, it will grow partition automatically.
    growPartition = true;
    # kernelParams = [ "console=ttyS0" ];

    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = lib.mkDefault 10;
      };
      efi.canTouchEfiVariables = true;
      timeout = lib.mkForce 3; # wait for 3 seconds to select the boot entry
    };

    initrd = {
      availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
      kernelModules = [ ];
    };

    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
    # clear /tmp on boot to get a stateless /tmp directory.
    tmp.cleanOnBoot = true;
  };


  fileSystems = {
    "/" =
      {
        device = "tmpfs";
        fsType = "tmpfs";
        options = [ "relatime" "mode=755" ];
      };

    "/nix" =
      {
        device = "/dev/disk/by-uuid/031752e4-b7af-4942-a62a-74650501fdb3";
        fsType = "btrfs";
        options = [ "noatime" "space_cache=v2" "compress-force=zstd" "ssd" "discard=async" "subvol=@nix" ];
      };

    "/persistent" =
      {
        device = "/dev/disk/by-uuid/031752e4-b7af-4942-a62a-74650501fdb3";
        fsType = "btrfs";
        options = [ "noatime" "space_cache=v2" "compress-force=zstd" "ssd" "discard=async" "subvol=@persistent" ];
        # impermance's data is required for booting
        neededForBoot = true;
      };

    "/snapshots" =
      {
        device = "/dev/disk/by-uuid/031752e4-b7af-4942-a62a-74650501fdb3";
        fsType = "btrfs";
        options = [ "noatime" "space_cache=v2" "compress-force=zstd" "ssd" "discard=async" "subvol=@snapshots" ];
      };

    "/boot" =
      {
        device = "/dev/disk/by-uuid/1E7C-94C1";
        fsType = "vfat";
      };
  };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.ens18.useDHCP = lib.mkDefault true;

  hardware = {
    # CPU
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}