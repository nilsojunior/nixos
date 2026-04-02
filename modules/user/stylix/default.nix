{
    config,
    lib,
    pkgs,
    inputs,
    osConfig,
    ...

}:
let
    cfg = config.userSettings.stylix;
    theme = import (../../themes + ("/" + config.userSettings.stylix.theme));
    font = config.userSettings.stylix.font;
in
{
    options = {
        userSettings.stylix = {
            enable = lib.mkEnableOption "Enables Stylix";
            theme = lib.mkOption {
                type = lib.types.str;
                default = "gruvbox-dark-hard";
                description = "Sets a theme for Stylix";
            };
            font.name = lib.mkOption {
                type = lib.types.str;
                default = "CaskaydiaCove Nerd Font";
                description = "Font name for Stylix";
            };
            font.package = lib.mkOption {
                type = lib.types.package;
                default = pkgs.nerd-fonts.caskaydia-cove;
                description = "Font package for Stylix";
            };
            font.size = lib.mkOption {
                type = lib.types.int;
                default = 19;
                description = "Font size for Stylix";
            };
        };
    };

    # Idk what's up with this, but without it i can't disable stylix
    # https://github.com/librephoenix/nixos-config/blob/main/modules/user/stylix/default.nix
    imports = lib.optionals (!osConfig.stylix.enable) [ inputs.stylix.homeManagerModules.stylix ];

    config = lib.mkIf cfg.enable {
        stylix = {
            enable = true;
            base16Scheme = theme;
            targets = {
                hyprland.enable = false;
                hyprlock.enable = false;
                vicinae.enable = false;
                kitty.fonts.enable = false;
                firefox = {
                    enable = false;
                    # enable = true;
                    # profileNames = [ "nilso" ];
                    # colorTheme.enable = true;
                    # colors.enable = true;
                };
            };

            fonts = {
                monospace = {
                    name = font.name;
                    package = font.package;
                };
                serif = {
                    name = font.name;
                    package = font.package;
                };
                sansSerif = {
                    name = font.name;
                    package = font.package;
                };
                emoji = {
                    name = "Twitter Color Emoji";
                    package = pkgs.twitter-color-emoji;
                };
                sizes = {
                    terminal = font.size;
                };
            };
        };
    };
}
