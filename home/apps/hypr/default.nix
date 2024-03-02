{ config, lib, inputs, system, ... }:

with lib;

let
  cfg = config.dotfiles.hypr;
in
{
  options.dotfiles.hypr = {
    profile = mkOption {
      type = types.str;
      default = "laptop";
      description = "host profile";
    };
  };

  config = {
    xdg.configFile."hypr".source = inputs."dotfiles-${cfg.profile}".packages.${system}.hypr + "/";
  };
}
