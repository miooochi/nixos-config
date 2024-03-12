{ sharedLib, lib, ... }:

with lib;
{
  imports = map sharedLib.relativeToRoot [
    # system modules
    "shared/nixos.nix"
    "system/users/server.nix"
    "system/users/init-pass.nix"
    "system/packages/server.nix"
    "system/environment/server.nix"
    "system/services/fish.nix"
    "system/services/openssh/server.nix"
    "system/services/zramd.nix"
    "system/internationalisation/locale.nix"
    "system/internationalisation/time.nix"
  ];

  sops.age.keyFile = mkForce "/run/keys/age-yubikey-master.key";
}
