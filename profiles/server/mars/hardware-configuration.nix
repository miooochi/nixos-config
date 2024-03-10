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
    # kernelParams = [ "console=ttyS0" ];
    extraModulePackages = [ ];
    extraModprobeConfig = ''
    '';

    tmp = {
      # Clear /tmp on boot to get a stateless /tmp directory.
      cleanOnBoot = true;
      # Size of tmpfs in percentage.
      tmpfsSize = "5%"; # default "50%"
    };
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
        # impermanence's data is required for booting
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

  hardware = {
    # CPU
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
