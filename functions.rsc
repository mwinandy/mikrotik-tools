{

    [import flash/mktools.env];

    :local watcherName "mktools-internet-availability";
    :local nws [/tool/netwatch/find (name=$watcherName)];
    :if ( [:len $nws] = 0 ) do={
        /tool/netwatch/add name=$watcherName host="1.1.1.1" interval=30s type=icmp startup-delay="0:0:20";
    }

    :global mkToolsTelegramSendMessage do={
        :global mkToolsEnvTelegramToken;
        :global mkToolsEnvTelegramChatID;
        :global mkToolsEnvTelegramThreadID;
        
        :local botToken $mkToolsEnvTelegramToken;
        
        :local data {
            "chat_id"=$mkToolsEnvTelegramChatID;
            "message_thread_id"=$mkToolsEnvTelegramThreadID;
            "text"=("$1");
        };
        
        :local api "https://api.telegram.org/bot$botToken";
        :local url "$api/sendMessage";

        :if ( ([/tool/netwatch/get mktools-internet-availability]->"status") = "up" ) do={
            [/tool/fetch http-method=post http-header-field="Content-Type:application/json" http-data=[:serialize $data to=json options=json.no-string-conversion] url="$url" output=none as-value];
        } else={
            :local msg "No internet for telegram notify.";
            :put $msg;
            /log/info message="$msg";
        }
        
    };

    :global mklog do={

        :global mkToolsTelegramSendMessage;

        :if ( [:len $1] > 0 ) do={
            :put "$1";
            /log/info message="$1";

            :if ( [:len $2] = 0 ) do={
                [$mkToolsTelegramSendMessage $1];
            };

        };

    };
    
    :global mkToolsGetCloudIP do={
        /ip/cloud/force-update;
        :delay 1s;
        :return [/ip/cloud/get public-address];
    };

    :global mkToolsGetCloudIPv6 do={
        /ip/cloud/force-update;
        :delay 1s;
        :return [/ip/cloud/get public-address-ipv6];
    };

    :global mkToolsEpoch do={
        :return [:pick [:tonsec [:timestamp]] 0 10];
    };
    
    :global mkToolsWaitInternet do={
        :global mklog;
        :while ( ([/tool/netwatch/get mktools-internet-availability]->"status") != "up" ) do={
            [$mklog "Waiting internet..."];
            :delay 15s;
        };
    };
    
    :global mkToolsGetIPv6 do={
        :local result [/tool fetch url="https://api6.ipify.org" http-method=get as-value output=user];
        :return ($result->"data");
    };

    :global mkToolsGetIPv4 do={
        :local result [/tool fetch url="https://api.ipify.org" http-method=get as-value output=user];
        :return ($result->"data");
    };

    :global mkToolsSplitIPv6 do={
        :local inputIPv6 ($1);
        :local resultArray [];
        
        :set ($resultArray->"prefix") "/128";
        
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
