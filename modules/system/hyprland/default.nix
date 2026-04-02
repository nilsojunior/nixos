{
    config,
    lib,
    pkgs,
    ...
}:
let
    cfg = config.systemSettings.hyprland;
in
{
    options = {
        systemSettings.hyprland.enable = lib.mkEnableOption "Enables Hyprland";
    };

    config = lib.mkIf cfg.enable {
        programs.hyprland.enable = true;
        environment.systemPackages = with pkgs; [
            xdg-desktop-portal-hyprland

            # Wayland
            wl-clipboard
        ];
    };
}
