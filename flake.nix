{
    description = "One flake to rule them all";

    inputs = {
        nixpkgs.url = "nixpkgs/nixos-unstable";
        nixpkgs-stable.url = "nixpkgs/nixos-25.11";

        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        firefox-addons = {
            url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        stylix = {
            url = "github:nix-community/stylix";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        vicinae = {
            url = "github:vicinaehq/vicinae";
            # inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs =
        {
            nixpkgs,
            nixpkgs-stable,
            home-manager,
            stylix,
            ...
        }@inputs:
        let
            system = "x86_64-linux";
            pkgs = import nixpkgs { inherit system; };
            pkgs-stable = import nixpkgs-stable { inherit system; };

            # Taken from here: https://github.com/librephoenix/nixos-config/blob/main/flake.nix
            # configure lib
            lib = inputs.nixpkgs.lib;

            # create a list of all directories inside of ./hosts
            # every directory in ./hosts has config for that machine
            hosts = builtins.filter (x: x != null) (
                lib.mapAttrsToList (name: value: if (value == "directory") then name else null) (
                    builtins.readDir ./hosts
                )
            );
        in
          {
              nixosConfigurations = builtins.listToAttrs (
                  map (host: {
                      name = host;
                      value = lib.nixosSystem {
                          system = "x86_64-linux";
                          modules = [
                              { config.networking.hostName = host; }
                              ./hosts/${host}/configuration.nix
                              home-manager.nixosModules.home-manager
                              stylix.nixosModules.stylix
                              {
                                  home-manager = {
                                      useGlobalPkgs = true;
                                      useUserPackages = true;
                                      backupFileExtension = "backup";
                                      extraSpecialArgs = {
                                          inherit inputs;
                                          inherit pkgs-stable;
                                      };
                                  };
                              }
                          ];
                          specialArgs = {
                              inherit pkgs-stable;
                              inherit inputs;
                          };
                      };
                  }) hosts
              );
          };
}
