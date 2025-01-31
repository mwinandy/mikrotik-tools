{
    [$waitInternet];

    :if (  ([/interface/lte/monitor "Freemobile 4G" once as-value]->"functionality") = "full" ) do={ 

        :local lteAddress [$splitIPv6 [$getCloudIPv6]];
        
        :if ( [:len [/ipv6/pool/find where (name="freemobile")]] = 0 ) do={
            /ipv6/pool/add name=freemobile prefix=2a0d:e487::/64 prefix-length=64;
        }
        
        :local pool ([/ipv6/pool/find where (name="freemobile")]->0);
        :local poolPrefix [$splitIPv6 [/ipv6/pool/get $pool prefix]];
        
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

    }


}