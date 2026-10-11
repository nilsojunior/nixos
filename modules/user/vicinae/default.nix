{
    config,
    lib,
    pkgs,
    inputs,
    ...
}:
let
    cfg = config.userSettings.vicinae;
in
{
    options = {
        userSettings.vicinae.enable = lib.mkEnableOption "Enables Vicinae";
    };

    imports = [ inputs.vicinae.homeManagerModules.default ];

    config = lib.mkIf cfg.enable {
        home.packages = with pkgs; [
            inter
        ];

        programs.vicinae = {
            enable = true;
            systemd = {
                enable = true;
                autoStart = true;
                environment = {
                    USE_LAYER_SHELL = 1;
                };
            };

        };

        home.file.".config/vicinae/extra.json".text =
            builtins.toJSON {
                launcher_window = {
                    dim_around = false;
                    blur.enabled = true;
                };
                favorites = [];
            };
    };
}
