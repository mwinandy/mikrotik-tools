{

    :if (  ([/interface/lte/monitor "4G" once as-value]->"functionality") = "full" ) do={ 
    
        :local lteInterface ([/ipv6/address/get ([/ipv6/address find where (actual-interface="4G" and global true and dynamic true)]->0)]);
        :local lteAddress ($lteInterface->"address");
    
        :local pool ([/ipv6/pool/find where (name="12LHIC_POOL")]->0);
        :local currentPoolPrefix [/ipv6/pool/get $pool prefix];
        
        :local prefixLTE [:pick (:tostr $lteAddress) 0 19];
        :local prefixPool [:pick (:tostr $currentPoolPrefix) 0 19];

        :if ( $prefixLTE != $prefixPool ) do={
    
            :local prefix ($prefixLTE."::/64");
            
            :local addressToDisable [/ipv6/address find where (from-pool="12LHIC_POOL")];
            
            :foreach address in=$addressToDisable do={
                /ipv6/address/disable $address;
            }
            
            /ipv6/pool/set $pool prefix=$prefix;
            
            :foreach address in=$addressToDisable do={
                /ipv6/address/enable $address;
            }

        }

    }

}