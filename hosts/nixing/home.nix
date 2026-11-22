{
    config,
    lib,
    pkgs, ...
}:
let
    common = import ./common.nix;
    monitors = {
        main   = "DP-2";
        second = "HDMI-A-1";
    };
in
{
    imports = [
        ../../modules/user
    ];

    userSettings = {
        mainMonitor = monitors.main;
        hyprland = {
            enable = common.hyprland.enable;
            nvidia = true;
            config = {
                monitor = [
                    {
                        output   = monitors.main;
                        mode     = "1920x1080@240";
                        position = "0x1080";
                    }
                    {
                        output   = monitors.second;
                        mode     = "1920x1080@60";
                        position = "0x0";
                    }
                ];
                workspace_rule = [
                    { workspace = 1; monitor = monitors.main; }
                    { workspace = 2; monitor = monitors.main; }
                    { workspace = 3; monitor = monitors.main; }
                    { workspace = 4; monitor = monitors.main; }
                    { workspace = 5; monitor = monitors.main; }
                    { workspace = 6; monitor = monitors.main; }
                    { workspace = 7; monitor = monitors.main; }
                    { workspace = 8; monitor = monitors.second; }
                    { workspace = 9; monitor = monitors.second; }
                    { workspace = 0; monitor = monitors.second; }
                ];
            };
        };
        zsh.enable     = true;
        browser        = "firefox";
        editor         = "emacs";
        terminal       = "kitty";
        keepass.enable = true;
        git.enable     = true;
        emacs.enable   = true;
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
