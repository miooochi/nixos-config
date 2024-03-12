{ inputs, lib, ... }:

{
  imports = [ inputs.home-estate.nixosModules.sdwan ];

  services.sdwan = {
    enable = lib.mkDefault true;
    autostart = lib.mkDefault false;
  };
}
