{ pkgs, ... }:

{
  xdg.configFile."bat/config".text = builtins.readFile ./config;
}
