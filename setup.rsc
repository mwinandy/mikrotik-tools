{

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
            "name"="onboot_update.rsc";
            "url"="https://raw.githubusercontent.com/mwinandy/mikrotik-tools/refs/heads/main/onboot_update.rsc"
            "target"="script"
        };
        {
            "name"="freemobileIPv6.rsc";
            "url"="https://raw.githubusercontent.com/mwinandy/mikrotik-tools/refs/heads/main/freemobileIPv6.rsc"
            "target"="script"
        };
        {
            "name"="mk_function.rsc";
            "url"="https://raw.githubusercontent.com/mwinandy/mikrotik-tools/refs/heads/main/function.rsc";
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
            
            :do {
                [/system/script/remove $scriptName];
            } on-error={};
            /system/script/add name=$scriptName dont-require-permissions=yes source=$source;
            
            :if ( $scriptTarget="run" ) do={
                /system/script/run $scriptName;
                /system/script/remove $scriptName;
            }
            :if ( $scriptTarget="script" ) do={
                #register
            }
            
            
            
            
            
        } on-error={
            :put "Fail: $scriptName"
        }

    };
    
    
    
}