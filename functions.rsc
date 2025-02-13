{

    [import flash/mktools.env];
    
    :global mklog do={
        :put "$1";
        /log/info message="$1";
    };
    
    :global mkToolsGetCloudIP do={
        /ip/cloud/force-update;
        :delay 1000ms;
        :return [/ip/cloud/get public-address];
    };

    :global mkToolsGetCloudIPv6 do={
        /ip/cloud/force-update;
        :delay 1000ms;
        :return [/ip/cloud/get public-address-ipv6];
    };

    :global mkToolsEpoch do={
        :return [:pick [:tonsec [:timestamp]] 0 10];
    };
    
    :global mkToolsWaitInternet do={
        :global mklog;
        :while ( ([/tool/netwatch/get mktools-internet-availability]->"status") != "up" ) do={
            [$mklog "Waiting internet..."];
        };
    };
    

    :global mkToolsSplitIPv6 do={
        :local inputIPv6 ($1);
        :local resultArray [];
        
        :set ($resultArray->"prefix") "/128";
        
        :local inputIPv6 ($1);
        
        :local prefixPos [:find $inputIPv6 "/"];
        
        :if ( !([:typeof $prefixPos] ~ "(nil|nothing)")) do={
            #AVEC PREFIX
            :set ($resultArray->"prefix") ([:pick $inputIPv6 $prefixPos [:len $inputIPv6] ]);
            :set inputIPv6 ([:pick $inputIPv6 0 $prefixPos]);
        }
        
        
        :local ip $inputIPv6;
        
        :foreach i in=[:range from=1 to=8] do={
        
            :local right [:find $ip ":"];
            :local block "";
        
            if ([:typeof $right] ~ "num") do={
                :set block ([:tostr [:pick $ip 0 $right ]]);
                :set ip ([:pick $ip ($right + 1) [:len $ip]]);
            } else={
                :set block ($ip);
                :set ip "0000";
            };
        
            :while ( [:len $block] < 4 ) do={ 
                :set block ("0".$block);
            }
        
            :set ($resultArray->"block_$i") $block;
                
        }
        
        :set ($resultArray->"ip") ($resultArray->"block_1");
        
        :foreach i in=[:range from=2 to=8] do={
                :set ($resultArray->"ip") ($resultArray->"ip".":".($resultArray->"block_$i"));
        }
        
        :set ($resultArray->"ip") ($resultArray->"ip".($resultArray->"prefix"));
            
        :return $resultArray;
    };
    

}
