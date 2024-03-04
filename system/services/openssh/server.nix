_:

{
  # enable openssh daemon
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes"; # enable root login for remote deploy
      PasswordAuthentication = true; # disable password login
    };
  };

  networking.firewall.allowedTCPPorts = [ 22 5598 ];
}