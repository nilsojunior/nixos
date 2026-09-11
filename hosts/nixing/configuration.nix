{
    config,
    lib,
    pkgs,
    ...
}:
let
    common = import ./common.nix;
in
{
    imports = [
        ./hardware-configuration.nix
        ../../modules/system
    ];

    nixpkgs.config.allowUnfreePredicate =
        pkg:
        builtins.elem (lib.getName pkg) [
            "nvidia-x11"
            "nvidia-settings"
            "spotify"
        ];

    systemSettings = {
        user            = "nilso";
        pipewire.enable = true;
        hyprland.enable = common.hyprland.enable;
        nvidia.enable   = true;
        stylix = {
            enable = common.stylix.enable;
            theme  = common.stylix.theme;
        };
    };

    services.udev.packages = [ pkgs.vial ];

    system.stateVersion = "25.11";
}
