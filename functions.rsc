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
    
        :local message $1
        :local mode $2
    
        :if ([:len $message] = 0) do={ :return }
    
        :if ([:len $mode] = 0) do={ :set mode "0" }
    
        # put toujours si mode = 0, 1, ou vide
        :if ($mode = "0" || $mode = "1" || [:len $2] = 0) do={
            :put "$message"
        }
    
        # log uniquement si mode = 1 ou 2 ou 3
        :if ($mode = "1" || $mode = "2" || $mode = "3") do={
            /log info message="$message"
        }
    
        # telegram uniquement si mode = 3 ou 4
        :if ($mode = "3" || $mode = "4") do={
            [$mkToolsTelegramSendMessage $message]
        }
    
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

        :local inputIPv6 ($1)
        :local resultArray []
        :set ($resultArray->"prefix") "/128"
    
        # Extraire /prefix si présent
        :local prefixPos [:find $inputIPv6 "/"]
        :if ([:typeof $prefixPos] != "nil") do={
            :set ($resultArray->"prefix") ([:pick $inputIPv6 $prefixPos [:len $inputIPv6]])
            :set inputIPv6 ([:pick $inputIPv6 0 $prefixPos])
        }
    
        :local blocks []
        :local doubleColonPos [:find $inputIPv6 "::"]
    
        :if ([:typeof $doubleColonPos] != "nil") do={
    
            :local leftPart [:pick $inputIPv6 0 $doubleColonPos]
            :local rightPart [:pick $inputIPv6 ($doubleColonPos + 2) [:len $inputIPv6]]
    
            # Découpage manuel de gauche
            :local leftBlocks []
            :if ([:len $leftPart] > 0) do={
                :local ip $leftPart
                :while ([:len $ip] > 0) do={
                    :local sepPos [:find $ip ":"]
                    :if ([:typeof $sepPos] = "nil") do={
                        :set leftBlocks ($leftBlocks , $ip)
                        :set ip ""
                    } else={
                        :set leftBlocks ($leftBlocks , [:pick $ip 0 $sepPos])
                        :set ip [:pick $ip ($sepPos + 1) [:len $ip]]
                    }
                }
            }
    
            # Découpage manuel de droite
            :local rightBlocks []
            :if ([:len $rightPart] > 0) do={
                :local ip $rightPart
                :while ([:len $ip] > 0) do={
                    :local sepPos [:find $ip ":"]
                    :if ([:typeof $sepPos] = "nil") do={
                        :set rightBlocks ($rightBlocks , $ip)
                        :set ip ""
                    } else={
                        :set rightBlocks ($rightBlocks , [:pick $ip 0 $sepPos])
                        :set ip [:pick $ip ($sepPos + 1) [:len $ip]]
                    }
                }
            }
    
            :local totalBlocks ([:len $leftBlocks] + [:len $rightBlocks])
            :local missingCount (8 - $totalBlocks)
    
            :foreach blk in=$leftBlocks do={ :set blocks ($blocks , $blk) }
            :for i from=1 to=$missingCount do={ :set blocks ($blocks , "0") }
            :foreach blk in=$rightBlocks do={ :set blocks ($blocks , $blk) }
    
        } else={
            # Découpage manuel complet
            :local ip $inputIPv6
            :while ([:len $ip] > 0) do={
                :local sepPos [:find $ip ":"]
                :if ([:typeof $sepPos] = "nil") do={
                    :set blocks ($blocks , $ip)
                    :set ip ""
                } else={
                    :set blocks ($blocks , [:pick $ip 0 $sepPos])
                    :set ip [:pick $ip ($sepPos + 1) [:len $ip]]
                }
            }
        }
    
        # Compléter si moins de 8 blocs
        :while ([:len $blocks] < 8) do={
            :set blocks ($blocks , "0")
        }
    
        # Normaliser chaque bloc à 4 chiffres hex
        :for i from=0 to=7 do={
            :local blk [:pick $blocks $i]
            :while ([:len $blk] < 4) do={
                :set blk ("0" . $blk)
            }
            :set ($resultArray->("block_" . ($i + 1))) $blk
        }
    
        # Reconstruction complète de l'IP
        :set ($resultArray->"ip") ($resultArray->"block_1")
        :for i from=2 to=8 do={
            :set ($resultArray->"ip") (($resultArray->"ip") . ":" . ($resultArray->("block_" . $i)))
        }
    
        :set ($resultArray->"ip") (($resultArray->"ip") . ($resultArray->"prefix"))
        :return $resultArray
    }


}
