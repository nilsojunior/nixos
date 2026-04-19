{
    config,
    lib,
    pkgs,
    ...
}:
let
    cfg = config.userSettings.git;
in
{
    options = {
        userSettings.git.enable = lib.mkEnableOption "Enables Git";
    };

    config = lib.mkIf cfg.enable {
        services.ssh-agent.enable = true;

        programs.git = {
            enable = true;
            signing.format = "ssh";
            signing.key = "~/.ssh/id_ed25519.pub";
            ignores = [
                "target/" # Rust
                ".direnv/"
                "TAGS"
                "build/"
            ];
        };

        programs.git.settings = {
            user = {
                name = "Nilso Júnior";
                email = "162613094+nilsojunior@users.noreply.github.com";
            };

            init.defaultBranch = "main";
            commit.gpgSign = true;
            push.autoSetupRemote = true;
            url = {
                "git@github.com:nilsojunior/" = {
                    insteadOf = "nj:";
                };
                "git@github.com:" = {
                    insteadOf = "gh:";
                };
            };
        };
    };
}
