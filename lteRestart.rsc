{
    
    [import flash/mktools/functions.rsc];
    
    :global mkToolsWaitInternet;

    [$mkToolsWaitInternet];

    :foreach iface in=[/interface/lte/find] do={
        /interface/lte/disable numbers=$iface;
        /interface/lte/enable numbers=$iface;
        import flash/mktools/freemobileIPv6.rsc;
    }
  
}
