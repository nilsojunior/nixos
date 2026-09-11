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
        ../../modules/user
    ];

    userSettings = {
        mainMonitor     = "eDP-1";
        laptop          = common.laptop;
        hyprland.enable = common.hyprland.enable;
        zsh.enable      = true;
        browser         = "firefox";
        editor          = "emacs";
        terminal        = "kitty";
        keepass.enable  = true;
        git.enable      = true;
        emacs.enable    = true;
        stylix = {
            enable = common.stylix.enable;
            theme  = common.stylix.theme;
        };
        spotify.enable = true;
        ssh.enable     = true;
        vicinae.enable = true;
    };

    home.stateVersion = "25.11";
}
