{

    [import flash/mktools/functions.rsc];
    
    :global mkToolsWaitInternet;

    [$mkToolsWaitInternet];

    [/tool fetch url="https://raw.githubusercontent.com/mwinandy/mikrotik-tools/refs/heads/main/setup.rsc" output=file dst-path="mktools-setup.rsc" as-value];
    import mktools-setup.rsc;
    /file/remove mktools-setup.rsc;

}