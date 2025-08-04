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
            
            # Extraction manuelle du préfixe /64 basé sur les 4 premiers blocs (19 caractères) du format IPv6 canonique (ex: xxxx:xxxx:xxxx:xxxx)
            :local prefixLTE [:pick ($freeMobileAddressIPv6->"ip") 0 19];
            :local prefixPool [:pick ($poolPrefixIPv6->"ip") 0 19];
            
            $mklog ("Current LTE prefix $prefixLTE") 1;
            $mklog ("Current pool prefix $prefixPool") 1;
            
            :if ( [:len $prefixLTE] = 0 || $prefixLTE != $prefixPool ) do={
                
                :local addressesToUpdate [/ipv6/address find where (from-pool="IPv6_POOL_FREEMOBILE" && disabled=no)]

                :foreach address in=$addressesToUpdate do={
                    /ipv6/address/disable numbers=$address;
                };
                
                :foreach poolItem in=$poolList do={
                   /ipv6/pool/set numbers=$poolItem prefix=($prefixLTE."::/64");
                };
                
                :foreach address in=$addressesToUpdate do={
                    /ipv6/address/enable numbers=$address;
                };
                
                :foreach nd in=[/ipv6/nd find where (disabled=no)] do={
                    /ipv6/nd/disable numbers=$nd;
                    /ipv6/nd/enable numbers=$nd;
                    $mklog ("Advertisement");
                };

                #Dummy rule for packet count
                :foreach rule in=[/ipv6/firewall/nat/find where (src-address~"^2a0d:e487")] do={
                    /ipv6/firewall/nat/set numbers=$rule src-address=($prefixLTE."::/64");  
                };
            
                #NAT Rule for active connection that's not from current prefix
                :foreach rule in=[/ipv6/firewall/nat/find where (src-address~"^!2a0d:e487")] do={
                    /ipv6/firewall/nat/set numbers=$rule src-address=("!".$prefixLTE."::/64");  
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
