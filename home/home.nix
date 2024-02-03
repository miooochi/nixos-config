{ config, pkgs, ... }:

let
  user = (import ../vars.nix).user;
in
{
  imports =
    map (d: ./apps + d)
      (map (n: "/" + n)
        (with builtins;attrNames
          (readDir ./apps)));

  programs.home-manager.enable = true;
  programs.go.enable = true;

  home.username = user;
  home.homeDirectory = "/home/${user}";
  home.stateVersion = "23.11";

  # fonts
  fonts.fontconfig.enable = true;
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    fira-code
    fira-code-symbols
    jetbrains-mono
    source-code-pro

    # icons
    material-design-icons
    
    # chinese fonts
    source-han-sans
    source-han-serif
  ];

  home.packages = with pkgs; [
    # fonts
    (pkgs.nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })

    # monitoring
    btop
    htop
    nvtop

    # networking
    dnsutils

    # essentials
    cmake
    fd
    ffmpeg
    fzf
    gcc
    ghostscript
    git
    github-cli
    gnumake
    graphicsmagick
    httpie
    lf
    minio-client
    neofetch
    ripgrep
    trash-cli
    unzip
    vivid
    yadm
    zip
    zoxide

    # encryption
    ccid
    gnupg
    pcsctools

    # window manager essentials
    xdg-user-dirs
    firefox
    kitty
    waybar
    dunst
    wofi

    # dev-toolings
    bat
    delta
    lazygit
    luajit
    neovim
    shfmt
    stylua
    tree-sitter
    waybar

    # devops-related
    ansible

    # rust-related
    rustc
    cargo

    # python-related
    python3
    black

    # nodejs-related
    nodePackages.prettier
    nodejs_latest
    yarn

    # go-related
    golangci-lint
    gopls
  ];

  # themes
  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.flat-remix-gtk;
      name = "Flat-Remix-GTK-Grey-Darkest";
    };
  
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
  };
}
