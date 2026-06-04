{ config, lib, pkgs, ... }:
{
    imports = [
        ../../modules/user
    ];

    userSettings = {
        mainMonitor = "DP-2";
        hyprland = {
            enable = true;
            nvidia = true;
            config = {
                "$main" = "DP-2";
                "$second" = "HDMI-A-1";
                monitor = [
                    "$main, 1920x1080@240, 0x1080, 1"
                    "$second, 1920x1080@60, 0x0, 1"
                ];
                workspace = [
                    "1, monitor:$main"
                    "2, monitor:$main"
                    "3, monitor:$main"
                    "4, monitor:$main"
                    "5, monitor:$main"
                    "6, monitor:$main"
                    "7, monitor:$main"
                    "8, monitor:$second"
                    "9, monitor:$second"
                    "10, monitor:$second"
                ];
            };
        };
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
