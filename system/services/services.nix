{ ... }:

{
  services = {
    # gvfs
    gvfs.enable = true;
    # openssh daemon
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false; # disable SSH password log in
    };
    # cronie
    cron = {
      enable = true;
      systemCronJobs = [
        "*/6 * * * *      root    date >> /tmp/cron.log"
      ];
    };
  };

  programs = {
    # gnupg-agent
    gnupg = {
      agent = {
        enable = false;
        pinentryFlavor = "curses";
        enableSSHSupport = true;
      };
    };
    fish.enable = true;
    hyprland.enable = true;
    dconf.enable = true;
  };

  zramSwap.enable = true;
  virtualisation.docker.enable = true;
}