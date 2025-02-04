{
    
    [/system/script/run mktools-functions.rsc];
    
    :global mkToolsWaitInternet;
    :global mkToolsSplitIPv6;
    
    [$mkToolsWaitInternet];

    :if (  ([/interface/lte/monitor "Freemobile 4G" once as-value]->"functionality") = "full" ) do={ 

        :local lteAddresses [/ipv6/address find where (interface="Freemobile 4G" and global true and dynamic true)];

        :if ( [:len $lteAddresses] = 1 ) do={

            /log/info message="LTE interface Freemobile Found";

            :local freeMobileAddress [/ipv6/address/get number=($lteAddresses->0)];

            /log/info message=("Freemobile IPv6: ".($freeMobileAddress->"address"));
            
            :local freeMobileAddressIPv6 [$mkToolsSplitIPv6 ($freeMobileAddress->"address")];
           
            :if ( [:len [/ipv6/pool/find where (name="freemobile")]] = 0 ) do={
                /ipv6/pool/add name=freemobile prefix=2a0d:e487::/64 prefix-length=64;
            }
#
            :local poolList [/ipv6/pool/find where (name="freemobile")];
            :local pool [/ipv6/pool/get number=($poolList->0)];
            :local poolPrefixIPv6 [$mkToolsSplitIPv6 ($pool->"prefix")];

            :local prefixLTE [:pick ($freeMobileAddressIPv6->"ip") 0 19];
            :local prefixPool [:pick ($poolPrefixIPv6->"ip") 0 19];

            /log/info message="Current LTE prefix $prefixLTE";
            /log/info message="Current pool prefix $prefixPool";
            
            :if ( $prefixLTE != $prefixPool ) do={

                :local addressToDisable [/ipv6/address find where (from-pool="freemobile")];
                #
                :foreach address in=$addressToDisable do={
                    /ipv6/address/disable numbers=$address;
                }
                
                :foreach poolItem in=$poolList do={
                   /ipv6/pool/set numbers=$poolItem prefix=($prefixLTE."::/64");
                }
                
                :foreach address in=$addressToDisable do={
                    /ipv6/address/enable numbers=$address;
                }
                
                /log/info message="Freemobile 4G Prefix updated";
                
            } else={
        
                /log/info message="Pool don't need update";
        
            }
        
        
        
        } else={
        
            :put "There's no Freemobile 4G interface";
        
        }
        

    }


}
