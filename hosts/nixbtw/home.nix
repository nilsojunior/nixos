{ config, lib, pkgs, ... }:
{
    imports = [
        ../../modules/user
    ];

    userSettings = {
        mainMonitor = "eDP-1";
        laptop = true;
        hyprland.enable = true;
        zsh.enable = true;
        browser = "firefox";
        editor = "emacs";
        terminal = "kitty";
        keepass.enable = true;
        git.enable = true;
        emacs.enable = true;
        stylix = {
            enable = true;
            theme = "gruvboxing";
        };
        spotify.enable = true;
        ssh.enable = true;
        vicinae.enable = true;
    };

    home.stateVersion = "25.11";
}
