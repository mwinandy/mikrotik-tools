{

:if (  ([/interface/lte/monitor "4G" once as-value]->"functionality") = "full" ) do={ 

    :local arrLteAddress [/ipv6/address/get ([/ipv6/address find where (actual-interface~"4G" and global true)]->0)]
    :global LteAddress ($arrLteAddress->"address");
    #:put $LteAddress;

    :local arrBridgeAddress [/ipv6/address/get ([/ipv6/address find where (actual-interface~"bridge1" and global true)]->0)]
    :global BridgeAddress ($arrBridgeAddress->"address");
    #:put $BridgeAddress;

    :local prefixLTE [:pick (:tostr $LteAddress) 0 19];
    :local prefixBridge [:pick (:tostr $BridgeAddress) 0 19];

    :put $prefixLTE;
    :put $prefixBridge;

    :if (  ([:pick (:tostr $LteAddress) 0 19] != [:pick (:tostr $BridgeAddress) 0 19])  ) do={ 

        :put "PAS OK";

        :local prefix ($prefixLTE."::/64");
        :put $prefix;

        /ipv6/address/disable ([/ipv6/address find where (actual-interface~"bridge1" and global true)]->0);
        /ipv6/pool/ set "12LHIC_POOL" prefix="$prefix";
        /ipv6/address/enable ([/ipv6/address find where (actual-interface~"bridge1" and global true)]->0);

    }
}

}
