{

    (import mktools/functions.rsc);
    
    :global mkToolsWaitInternet;

    [$mkToolsWaitInternet];

    :put "Should do an update !";

    [/tool fetch url="https://raw.githubusercontent.com/mwinandy/mikrotik-tools/refs/heads/main/setup.rsc" output=file dst-path="mktools-setup.rsc" as-value];

    import mktools-setup.rsc;
    
    /file/delete mktools-setup.rsc;

}