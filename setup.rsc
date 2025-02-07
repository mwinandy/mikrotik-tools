{

    :do {
        /tool/netwatch/remove "mktools-internet-availability";
    } on-error={};
    /tool/netwatch/add name="mktools-internet-availability" host="1.1.1.1" interval=30s type=icmp

    :local download do={
        :local path ("temp".[:pick [:tonsec [:timestamp]] 0 10]);
        :do {
            [/file/remove $path];
        } on-error={};
        [/tool fetch url="$1" output=file dst-path=$path as-value];
        :local content [/file/get $path contents];
        [/file/remove $path];
        :return $content;
    }
    
    :do {
        /file/add type=directory name="mktools";
    } on-error={};

    :local scripts {
        {
            "name"="onboot_update.rsc";
            "url"="https://raw.githubusercontent.com/mwinandy/mikrotik-tools/refs/heads/main/onboot_update.rsc"
            "target"="file"
        };
        {
            "name"="freemobileIPv6.rsc";
            "url"="https://raw.githubusercontent.com/mwinandy/mikrotik-tools/refs/heads/main/freemobileIPv6.rsc"
            "target"="file"
        };
        {
            "name"="functions.rsc";
            "url"="https://raw.githubusercontent.com/mwinandy/mikrotik-tools/refs/heads/main/functions.rsc";
            "target"="file"
        };
        
    }
    
    :foreach script in=$scripts do={
        
        :local scriptName ($script->"name");
        :local scriptPath "flash/mktools/$scriptName";
        :local scriptUrl ($script->"url");
        :local scriptTarget ($script->"target");
        :local scriptReplace ($script->"replace");
        :local scriptSource [$download $scriptUrl];
                
        :do {
            :put "Download: $scriptName to $scriptPath";

            :if ( $scriptTarget="file" ) do={
                
                :do {
                    /file/remove $scriptPath
                } on-error={};
                
                /file/add type=file name=$scriptPath content=$scriptSource;
            };
            
        } on-error={
            :put "Fail: $scriptName"
        }

    };
    
    
    :do {
        [/system/scheduler/remove "onboot_update"];
    } on-error={};
    /system/scheduler/add name="onboot_update" start-time=startup interval="0:15:0" on-event="import flash/mktools/onboot_update.rsc;";
    
    
    
}
