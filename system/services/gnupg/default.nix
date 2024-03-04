{ pkgs, ... }:

# Reference: https://nixos.wiki/wiki/Yubikey
{
  environment.systemPackages = with pkgs; [
    ccid # ccid drivers for pcsclite
    gnupg
    libfido2
    libu2f-host
    libusb-compat-0_1
    opensc # Set of libraries and utilities to access smart cards
    pam_u2f
    pcsctools # Tools used to test a PC/SC driver, card or reader
    pinentry # GnuPG’s interface to passphrase input
    yubico-pam
    yubikey-personalization # A library and command line tool to personalize YubiKeys
  ];

  services = {
    # install necessary udev packages
    udev.packages = with pkgs; [
      libu2f-host
      yubikey-personalization
    ];
    # enable pcscd
    pcscd.enable = true;
  };

  # reset gpg-agent
  environment.shellInit = ''
    /run/current-system/sw/bin/gpg-connect-agent /bye
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  '';

  programs = {
    # disable ssh-agent
    ssh.startAgent = false;

    # gnupg-agent
    gnupg = {
      agent = {
        enable = true;
        pinentryFlavor = "curses";
        enableSSHSupport = true;
        # /etc/gnupg/gpg-agent.conf
        settings = {
          enable-ssh-support = "";
          ttyname = "$GPG_TTY";
          default-cache-ttl = 60;
          max-cache-ttl = 120;
          allow-loopback-pinentry = "";
        };
      };
    };
  };
}
