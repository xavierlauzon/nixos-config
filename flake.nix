{
  description = "Xavier's NixOS Configuration";

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
    extra-substituters = [
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
      "https://nix-gaming.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
    ];
  };

  inputs = {
    nixpkgs-25-05.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-25-05-small.url = "github:NixOS/nixpkgs/nixos-25.05-small";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable-small.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    home-manager-25-05 = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs-25-05";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    apple-silicon = {
      url = "github:nix-community/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-modules = {
      #url = "github:xavierlauzon/nixos-modules";
      url = "path:/home/xavier/src/nixos-modules";
    };
    nix-networkd = {
      #url = "github:xavierlauzon/nixos-modules";
      url = "path:/home/xavier/src/gh/nix-networkd";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    herald = {
      url = "github:nfrastack/herald";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
    };
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    minecraft-plymouth-theme = {
      url = "github:nikp123/minecraft-plymouth-theme";
    };
    zeroplex = {
      url = "github:nfrastack/zeroplex";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      inherit (self) outputs;
      lib = inputs.nixpkgs-25-05.lib;
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];

      # Supported nixpkgs versions
      supportedVersions = {
        "25.05" = {
          nixpkgs = inputs.nixpkgs-25-05;
          home-manager = inputs.home-manager-25-05;
        };
        "25.05-small" = {
          nixpkgs = inputs.nixpkgs-25-05-small;
          home-manager = inputs.home-manager-25-05;
        };
        unstable = {
          nixpkgs = inputs.nixpkgs-unstable;
          home-manager = inputs.home-manager-unstable;
        };
        "unstable-small" = {
          nixpkgs = inputs.nixpkgs-unstable-small;
          home-manager = inputs.home-manager-unstable;
        };
      };

      # Create package sets for each system
      forAllSystems = f: lib.genAttrs systems (system: f system);

      # Generate overlay with all nixpkgs versions
      nixpkgsVersionsOverlay = final: prev:
        lib.mapAttrs (name: version:
          import version.nixpkgs {
            inherit (prev) system;
            config.allowUnfree = true;
            overlays = [];
          }
        ) supportedVersions;

      pkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
            outputs.overlays.additions
            outputs.overlays.modifications
            outputs.overlays.stable-packages
            outputs.overlays.unstable-packages
        ];
      });

      forEachSystem = f: lib.genAttrs systems (sys: f pkgsFor.${sys});
    in
    {
      inherit lib;
      formatter = forEachSystem (pkgs: pkgs.nixpkgs-fmt);

      overlays = import ./overlays {inherit inputs; additions = final: prev: {
      };};
      packages = forEachSystem (pkgs: import ./pkgs { inherit pkgs; });

      mkSystem = { hostPath, packages ? "25.05", system ? "x86_64-linux", extraModules ? [] }:
        let
          # nixpkgs mapping from supportedVersions
          nixpkgsMapping = lib.mapAttrs (name: version: version.nixpkgs) supportedVersions;

          # home-manager mapping from supportedVersions
          homeManagerMapping = lib.mapAttrs (name: version: version.home-manager) supportedVersions;

          selectedNixpkgs = nixpkgsMapping.${packages} or (throw "Unknown package selection: ${packages}");
          selectedHomeManager = homeManagerMapping.${packages} or (throw "Unknown package selection: ${packages}");

          # Generate overlay attributes dynamically
          versionOverlayAttrs = lib.mapAttrs (name: version:
            import version.nixpkgs {
              inherit system;
              config.allowUnfree = true;
              overlays = [];
            }
          ) supportedVersions;

          systemPkgs = import selectedNixpkgs {
            inherit system;
            config = {
              allowUnfree = true;
              allowBroken = false;
              allowUnsupportedSystem = true;
            };
            overlays = builtins.attrValues outputs.overlays ++ [
              (final: prev: versionOverlayAttrs)
            ];
          };
        in
        selectedNixpkgs.lib.nixosSystem {
          modules = [
            selectedHomeManager.nixosModules.home-manager
            hostPath
            {
              _module.args.nixpkgsBranch = packages;
            }
          ] ++ extraModules;
          specialArgs = {
            inherit self inputs outputs;
            home-manager = selectedHomeManager;
          };
          inherit (systemPkgs) system;
          pkgs = systemPkgs;
        };

      nixosConfigurations = {
        hellfire = self.mkSystem {
          hostPath = ./hosts/hellfire;
          packages = "unstable";
        };

        maverick = self.mkSystem {
          hostPath = ./hosts/maverick;
          packages = "unstable";
        };

        paveway = self.mkSystem {
          hostPath = ./hosts/paveway;
          packages = "unstable";
        };

        falcon = self.mkSystem {
          hostPath = ./hosts/falcon;
          packages = "25.05";
        };

        blackhawk = self.mkSystem {
          hostPath = ./hosts/blackhawk;
          packages = "unstable";
        };

        xavierdesktop = self.mkSystem {
          hostPath = ./hosts/xavierdesktop;
          packages = "unstable";
        };

        rescue = self.mkSystem {
          hostPath = ./hosts/rescue;
          packages = "25.05";
          system = "x86_64-linux";
        };

      };

      profiles = lib.mkOption {
        type = with lib.types; attrsOf (attrsOf anything);
        default = {};
      };
    };
}
