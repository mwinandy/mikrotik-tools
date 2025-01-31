{

    :do {
        /tool/netwatch/remove "mktools-internet-availability";
    } on-error={};
    /tool/netwatch/add name="mktools-internet-availability" host="1.1.1.1" interval=1m type=icmp down-script="{ :global mktoolsInternetIsReady \"no\" }" up-script="{ :global mktoolsInternetIsReady \"yes\" }"

    :local download do={
        :local path ("temp".[$epoch]);
        :do {
            [/file/remove $path];
        } on-error={};
        [/tool fetch url="$1" output=file dst-path=$path as-value];
        :local content [/file/get $path contents];
        [/file/remove $path];
        :return $content;
    }

    :local scripts {
        {
            "name"="mktools-onboot_update.rsc";
            "url"="https://raw.githubusercontent.com/mwinandy/mikrotik-tools/refs/heads/main/onboot_update.rsc"
            "target"="script"
            "replace"="false"
        };
        {
            "name"="mktools-freemobileIPv6.rsc";
            "url"="https://raw.githubusercontent.com/mwinandy/mikrotik-tools/refs/heads/main/freemobileIPv6.rsc"
            "target"="script"
        };
        {
            "name"="mktools-mk_function.rsc";
            "url"="https://raw.githubusercontent.com/mwinandy/mikrotik-tools/refs/heads/main/function.rsc";
            "target"="script"
        };
        
    }
    
    :foreach script in=$scripts do={
        
        :local scriptName ($script->"name");
        :local scriptUrl ($script->"url");
        :local scriptTarget ($script->"target");
        :local scriptReplace ($script->"replace");
        
        :do {
            :put "Download: $scriptName"
            :local source [$download $scriptUrl];
            
                :if ( $scriptReplace != "false" ) do={
                    :do {
                        [/system/script/remove $scriptName];
                    } on-error={};
                }
                
                :do {
                    /system/script/add name=$scriptName dont-require-permissions=yes source=$source;
                } on-error={};
                

                :if ( $scriptTarget="run" ) do={
                    /system/script/run $scriptName;
                    /system/script/remove $scriptName;
                }
                :if ( $scriptTarget="script" ) do={
                    #register
                }

            :do {
                [/system/scheduler/remove "mktools-onboot_update"];
            } on-error={};
            /system/scheduler/add name="mktools-onboot_update" start-time=startup on-event="/system/script/run mktools-onboot_update.rsc"

        } on-error={
            :put "Fail: $scriptName"
        }

    };
    
    
    
}