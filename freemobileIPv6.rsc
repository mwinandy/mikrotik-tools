{
    
    [import flash/mktools/functions.rsc];
    
    :global mkToolsWaitInternet;
    :global mkToolsSplitIPv6;
    :global mklog;

    [$mkToolsWaitInternet];
    
    :if ( ([/interface/lte/monitor "Freemobile 4G" once as-value]->"functionality") = "full" ) do={ 
        
        :local lteAddresses [/ipv6/address find where (interface="Freemobile 4G" and global true and dynamic true)];
        
        :if ( [:len $lteAddresses] = 1 ) do={
            
            :put "LTE interface Freemobile Found";
            
            :local freeMobileAddress [/ipv6/address/get number=($lteAddresses->0)];
            
            :put ("Freemobile IPv6: ".($freeMobileAddress->"address"));
            
            :local freeMobileAddressIPv6 [$mkToolsSplitIPv6 ($freeMobileAddress->"address")];
            :put $freeMobileAddressIPv6;
           
            :if ( [:len [/ipv6/pool/find where (name="freemobile")]] = 0 ) do={
                /ipv6/pool/add name=freemobile prefix=2a0d:e487::/64 prefix-length=64;
            }
            
            :local poolList [/ipv6/pool/find where (name="freemobile")];
            :local pool [/ipv6/pool/get number=($poolList->0)];
            :local poolPrefixIPv6 [$mkToolsSplitIPv6 ($pool->"prefix")];
            :put $poolPrefixIPv6;
            
            :local prefixLTE [:pick ($freeMobileAddressIPv6->"ip") 0 19];
            :local prefixPool [:pick ($poolPrefixIPv6->"ip") 0 19];
            
            :put "Current LTE prefix $prefixLTE";
            :put "Current pool prefix $prefixPool";
            
            :if ( [:len $prefixLTE] = 0 || $prefixLTE != $prefixPool ) do={
                
                :local addressToDisable [/ipv6/address find where (from-pool="freemobile")];
                
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
                :put "Freemobile pool don't need update";
            }
        } else={
            $mklog "There's no Freemobile 4G interface";
        }
    }
}
