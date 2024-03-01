{ pkgs, ... }:

{
  i18n.defaultLocale = (import ../../vars.nix).defaultLocale;
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      fcitx5-chinese-addons
      fcitx5-material-color
    ];
  };
}
