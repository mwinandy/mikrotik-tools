{
    
    [/system/script/run mktools-functions.rsc];
    
    [$mkToolsWaitInternet];

    :if (  ([/interface/lte/monitor "Freemobile 4G" once as-value]->"functionality") = "full" ) do={ 

        :local lteInterfaceList [/ipv6/address find where (actual-interface="Freemobile 4G" and global true and dynamic true)];
        
        :if ( [:len $lteInterfaceList] = 1 ) do={
        
            :local lteInterface ([/ipv6/address/get ($lteInterfaceList->0)]);

            :local lteAddress [$mkToolsSplitIPv6 ($lteInterface->"address")];
        
            :if ( [:len [/ipv6/pool/find where (name="freemobile")]] = 0 ) do={
                /ipv6/pool/add name=freemobile prefix=2a0d:e487::/64 prefix-length=64;
            }
        
            :local pool ([/ipv6/pool/find where (name="freemobile")]->0);
            :local poolPrefix [$mkToolsSplitIPv6 [/ipv6/pool/get $pool prefix]];
        
            :local prefixLTE [:pick ($lteAddress->"ip") 0 19];
            :local prefixPool [:pick ($poolPrefix->"ip") 0 19];
        
            :if ( $prefixLTE != $prefixPool ) do={
        
                :local addressToDisable [/ipv6/address find where (from-pool="freemobile")];
                :foreach address in=$addressToDisable do={
                    /ipv6/address/disable $address;
                }
        
                /ipv6/pool/set $pool prefix=($prefixLTE."::/64");
        
                :foreach address in=$addressToDisable do={
                    /ipv6/address/enable $address;
                }
                :log info "Freemobile 4G Prefix updated";
            }
        
        
        
        } else={
        
            :put "There's no Freemobile 4G interface";
        
        }
        

    }


}
