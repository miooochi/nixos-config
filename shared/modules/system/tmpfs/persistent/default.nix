{ config, inputs, user, lib, ... }:

with lib;
let
  cfg = config.modules.persistent;
  inherit (import ./dirs/common-home-special-dirs.nix { }) commonSpecialDirs;
in
{
  imports = [
    inputs.impermanence.nixosModules.impermanence
    ./nix-daemon.nix
  ];

  options.modules.persistent = {
    enable = mkEnableOption "Load persistent settings";
    hostType = mkOption {
      type = types.str;
      default = "workstation";
      description = "Host type; [ workstation server ]";
    };
  };

  config = mkIf cfg.enable (
    mkMerge [
      # common attrs
      { environment.persistence."/persistent".hideMounts = true; }

      # workstation specific attrs
      (mkIf (cfg.hostType == "workstation") {
        environment.persistence."/persistent" = {
          # system dirs and files to map
          directories = import ./dirs/common-system-dirs.nix;
          files = import ./files/workstation-system-specific.nix;

          # home dirs and files to map
          users.${user} = {
            directories = (import ./dirs/common-home-dirs.nix) ++
              (import ./dirs/common-misc-dirs.nix) ++
              (import ./dirs/common-xdg-dirs.nix) ++
              (import ./dirs/extra-xdg-dirs.nix) ++
              commonSpecialDirs;
            # excluded; conflicts with sops-nix
            # ".gitconfigs
            # ".mc"

            files = (import ./files/workstation-home-specific.nix) ++
              (import ./files/common-home-files.nix);
            # excluded; conflicts with sops-nix
            # ".gitconfig
            # ".tmux.conf
          };
        };
      })

      # server specific attrs
      (mkIf (cfg.hostType == "server") {
        environment.persistence."/persistent" = {
          # system dirs and files to map
          directories = import ./dirs/common-system-dirs.nix;

          files = [ "/etc/machine-id" ];

          # home dirs and files to map
          users.${user} = {
            directories = (import ./dirs/common-home-dirs.nix) ++
              commonSpecialDirs;

            files = import ./files/common-home-files.nix;
            # excluded; conflicts with sops-nix
            # ".gitconfig
          };
        };
      })
    ]
  );
}
