{
    
    [import flash/mktools/functions.rsc];
    
    :global mkToolsWaitInternet;
    :global mkToolsSplitIPv6;
    :global mklog;

    [$mkToolsWaitInternet];
    
    :if ( ([/interface/lte/monitor "LTE" once as-value]->"status") = "running" ) do={ 
        
        :local lteAddresses [/ipv6/address find where (interface="LTE" and global true and dynamic true)];
        
        :if ( [:len $lteAddresses] = 1 ) do={
            
            $mklog ("LTE interface Freemobile Found") 1;
            
            :local freeMobileAddress [/ipv6/address/get number=($lteAddresses->0)];
            
            $mklog ("Freemobile IPv6: ".($freeMobileAddress->"address")) 1;
            
            :local freeMobileAddressIPv6 [$mkToolsSplitIPv6 ($freeMobileAddress->"address")];
            $mklog ($freeMobileAddressIPv6) 1;
           
            :if ( [:len [/ipv6/pool/find where (name="IPv6_POOL_FREEMOBILE")]] = 0 ) do={
                /ipv6/pool/add name="IPv6_POOL_FREEMOBILE" prefix=2a0d:e487::/64 prefix-length=64;
            }
            
            :local poolList [/ipv6/pool/find where (name="IPv6_POOL_FREEMOBILE")];
            :local pool [/ipv6/pool/get number=($poolList->0)];
            :local poolPrefixIPv6 [$mkToolsSplitIPv6 ($pool->"prefix")];
            $mklog ($poolPrefixIPv6) 1;
            
            :local prefixLTE [:pick ($freeMobileAddressIPv6->"ip") 0 19];
            :local prefixPool [:pick ($poolPrefixIPv6->"ip") 0 19];
            
            $mklog ("Current LTE prefix $prefixLTE") 1;
            $mklog ("Current pool prefix $prefixPool") 1;
            
            :if ( [:len $prefixLTE] = 0 || $prefixLTE != $prefixPool ) do={
                
                :local addressToDisable [/ipv6/address find where (from-pool="IPv6_POOL_FREEMOBILE")];
                
                :foreach address in=$addressToDisable do={
                    /ipv6/address/disable numbers=$address;
                };
                
                :foreach poolItem in=$poolList do={
                   /ipv6/pool/set numbers=$poolItem prefix=($prefixLTE."::/64");
                };
                
                :foreach address in=$addressToDisable do={
                    /ipv6/address/enable numbers=$address;
                };

                $mklog ("Freemobile pool prefix updated from $prefixPool to $prefixLTE");
                
            } else={
                $mklog "Freemobile pool don't need update" 1;
            }
        } else={
            $mklog "There's no Freemobile 4G with IPv6 interface";
        }
    }
}
