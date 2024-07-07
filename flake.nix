{
  # NixOS configuration (with HomeManager)
  # build system
  outputs = { nixpkgs, home-manager, ... }@inputs: with inputs;
    let
      system = "x86_64-linux";
      inherit (import ./profiles.nix { }) profiles;
      inherit (import ./shared/overlays { inherit inputs; }) overlays;
      # use a system-specific version of nixpkgs
      pkgs = (import nixpkgs) { inherit system overlays; config.allowUnfree = lib.mkDefault true; };
      inherit (nixpkgs) lib;
      inherit (import ./shared/vars) user;
      specialArgs = genSpecialArgs system;
      extraModules = [
        sops-nix.nixosModules.sops
      ];
      # function to generate specialArgs
      genSpecialArgs = system: {
        pkgs-small = (import nixpkgs-small) { inherit system; config.allowUnfree = lib.mkDefault true; };
        inherit (import ./shared/lib { inherit lib; }) sharedLib;
        inherit inputs pkgs system user;
      };
      # function to generate homeModule
      genHomeModules = homeModules: [
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = specialArgs;
            users.${user} = homeModules;
            sharedModules = [
              sops-nix.homeManagerModules.sops
            ];
          };
        }
      ];
      # function to generate nixosSystem
      genSystem =
        { profile
        , isServer ? false
        , profilePrefix ? (if (!isServer) then ./profiles/workstation/${profile.hostname} else ./profiles/server/${profile.hostname})
        , hostModules ? (
            [ (profilePrefix + "/configuration.nix") ] ++ (lib.optionals (!isServer) [
              hyprland.nixosModules.default
              chaotic.nixosModules.default
            ])
          )
        , homeModules ? lib.optionals profile.home-manager (genHomeModules (import (profilePrefix + "/home.nix")))
        }: lib.nixosSystem {
          inherit specialArgs;
          modules = hostModules ++ homeModules ++ extraModules;
        };
      # function to generate remote deploy nixosSystem
      genDeploy =
        { profile
        , hostModules ? [ ./profiles/server/${profile.hostname}/configuration.nix ]
        , homeModules ? lib.optionals profile.home-manager (genHomeModules (import ./profiles/server/${profile.hostname}/home.nix))
        }: {
          deployment = {
            targetHost = "nixos-${profile.hostname}";
            inherit (import ./shared/vars) targetPort targetUser tags;
            inherit (profile) keys;
          };
          imports = hostModules ++ homeModules ++ extraModules;
        };
      # function to generate nixosSystem for microvm
      genMicroVM =
        { profile
        , hostModules ? [
            microvm.nixosModules.microvm
            (import ./shared/modules/microvm/${profile.hostname}.nix)
          ]
        }: lib.nixosSystem {
          inherit specialArgs;
          modules = hostModules;
        };
      # function to generate nixosConfigurations with flake
      genFlake = profiles: with profiles; (
        # (lib.attrsets.mergeAttrsList): merge attribute sets, expect input as a list
        lib.attrsets.mergeAttrsList (
          # (map): instantiate nixosConfigurations.${profile} from inputs
          (map (profile: { ${profile.hostname} = genSystem { inherit profile; }; }) workstations) ++
          (map (profile: { ${profile.hostname} = genSystem { inherit profile; isServer = true; }; }) servers) ++
          (map (profile: { "${profile.hostname}-microvm" = genMicroVM { inherit profile; }; }) microvms)
        ));
      # function to generate colemna configs with flake for remote deploy
      genColmena = servers: (
        { meta = { nixpkgs = pkgs; inherit specialArgs; }; } //
        # (lib.attrsets.mergeAttrsList): merge attribute sets, expect input as a list
        lib.attrsets.mergeAttrsList (map (profile: { ${profile.hostname} = genDeploy { inherit profile; }; }) servers)
      );
      # function to generate pre-commit-checks
      genChecks = system: (pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          nixpkgs-fmt.enable = true; # formatter
          statix.enable = true; # linter
          deadnix.enable = true; # linter
        };
      });
      # function to generate nix packages
      genPkgs = microvms: lib.attrsets.mergeAttrsList (map
        (profile: {
          "${profile.hostname}-microvm" = self.nixosConfigurations."${profile.hostname}-microvm".config.microvm.declaredRunner;
          nix-fast-build = inputs.nix-fast-build.packages.${system}.default;
        })
        microvms
      );
    in
    with profiles;
    {
      # checks
      checks.${system}.pre-commit-check = genChecks system;
      # hosts
      nixosConfigurations = genFlake profiles;
      # remote deploy
      colmena = genColmena servers;
      # packages
      packages.${system} = genPkgs microvms;
    };

  inputs = {
    # public source
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-small.url = "github:nixos/nixpkgs/nixos-unstable-small";
    pilots.url = "github:NixOS-Pilots/pilots";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    chaotic-kernel.url = "github:chaotic-cx/nyx/5b48d005e7b5250de7d5f466d8d87ef71a10ecff";
    home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
    sops-nix.url = "github:Mic92/sops-nix";
    nixpkgs-wayland = { url = "github:nix-community/nixpkgs-wayland"; inputs.nixpkgs.follows = "nixpkgs"; };
    hyprland = { url = "git+https://github.com/hyprwm/Hyprland?tag=v0.41.2&submodules=1"; };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    impermanence.url = "github:nix-community/impermanence";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    microvm = { url = "github:astro/microvm.nix"; inputs.nixpkgs.follows = "nixpkgs"; };
    nix-fast-build.url = "github:Mic92/nix-fast-build";

    # personal nur
    nur.url = "github:piyoki/nur-packages";
    assets.url = "github:piyoki/nur-assets";

    # private repos
    secrets = { url = "git+ssh://git@github.com/piyoki/sops-credentials.git?shallow=1"; flake = false; };
    home-estate = { url = "git+ssh://git@github.com/piyoki/home-estate.git?shallow=1"; };

    # personal dotfiles
    dotfiles.url = "git+https://github.com/piyoki/dotfiles.nix?ref=master";
  };
}
