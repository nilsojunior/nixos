{
    config,
    lib,
    pkgs,
    ...
}:
let
    cfg = config.systemSettings.kanata;
in
{
    options = {
        systemSettings.kanata.enable = lib.mkEnableOption "Enables Kanata";
    };

    config = lib.mkIf cfg.enable {
        services.kanata.enable = true;
        services.kanata.keyboards = {
            default = {
                config = ''
(defsrc
    esc    f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12
    grv    1    2    3    4    5    6    7    8    9    0    -    =   bspc
    tab    q    w    e    r    t    y    u    i    o    p    [    ]   \
    caps   a    s    d    f    g    h    j    k    l    ;    '    ret
    lsft < z    x    c    v    b    n    m    ,    .    /    rsft      up
    lctl   lmet lalt           spc            ralt ro          left down rght
)

(defalias
    esctrl (tap-hold-press 150 150 esc lctrl)
)

(deflayer qwerty
  esc        f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12
  \          1    2    3    4    5    6    7    8    9    0    -    =   bspc
  tab        q    w    e    r    t    y    u    i    o    p    [    ]   grv
  @esctrl    a    s    d    f    g    h    j    k    l    ;    '    ret
  lsft   esc z    x    c    v    b    n    m    ,    .    /    rsft          up
  lctl       lmet lalt           spc            ralt rmet               left down rght
)
                '';
            };
        };
    };
}
