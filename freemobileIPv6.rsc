{

    :if (  ([/interface/lte/monitor "4G" once as-value]->"functionality") = "full" ) do={ 
    
        :local lteInterface ([/ipv6/address/get ([/ipv6/address find where (actual-interface="4G" and global true and dynamic true)]->0)]);
        :local lteAddress [$splitIPv6 ($lteInterface->"address")];
    
        :local pool ([/ipv6/pool/find where (name="12LHIC_POOL")]->0);
        :local poolAddress [$splitIPv6 [/ipv6/pool/get $pool prefix]];

        :local prefixLTE [:pick ($lteAddress->"ip") 0 19];
        :local prefixPool [:pick ($poolAddress->"ip") 0 19];

        :if ( $prefixLTE != $prefixPool ) do={
            :put "A CHANGER";

            :local addressToDisable [/ipv6/address find where (from-pool="12LHIC_POOL")];

            :foreach address in=$addressToDisable do={
                /ipv6/address/disable $address;
            }

            /ipv6/pool/set $pool prefix=($prefixLTE."::/64");

            :foreach address in=$addressToDisable do={
                /ipv6/address/enable $address;
            }
        
        }

    }

}