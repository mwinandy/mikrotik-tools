{

    :local download do={
        ([/tool fetch url="$1" output=file dst-path="fetch.temp" as-value]);
        :local content [/file/get "fetch.temp" contents];
        [/file/remove "fetch.temp"];
        :return $content;
    }

    :local scripts {
        {
            "name"="freemobileIPv6.p6";
            "url"="https://raw.githubusercontent.com/mwinandy/mikrotik-tools/refs/heads/main/freemobileIPv6.p6"
            "target"="script"
        };
        {
            "name"="mk_function.p6";
            "url"="https://raw.githubusercontent.com/mwinandy/mikrotik-tools/refs/heads/main/function.p6";
            "target"="run"
        };
        
    }
    
    :foreach script in=$scripts do={
        
        :local scriptName ($script->"name");
        :local scriptUrl ($script->"url");
        :local scriptTarget ($script->"target");
        
        :do {
            :put "Download: $scriptName"
            :local source [$download $scriptUrl];
            :if ( $scriptTarget="run" ) do={
                :parse $source;
            }
            :if ( $scriptTarget="script" ) do={
                :do {
                    [/system/script/remove $scriptName];
                } on-error={};
                /system/script/add name=$scriptName dont-require-permissions=yes source=$source;
            }
        } on-error={
            :put "Fail: $scriptName"
        }

    };
    
    
    
}