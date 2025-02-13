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
        /file/add type=directory name="flash/mktools";
    } on-error={};
    
    :do {
        /file/add type=file name="flash/mktools.env";
    } on-error={};
    
    [import "flash/mktools.env"];

    :local scripts {
        {
            "url"="https://raw.githubusercontent.com/mwinandy/mikrotik-tools/refs/heads/main/onboot_update.rsc";
            "path"="flash/mktools/onboot_update.rsc"
            "script"="MkToolsOnBootUpdate";
            "command"="import flash/mktools/onboot_update.rsc;";
        };
        {
            "url"="https://raw.githubusercontent.com/mwinandy/mikrotik-tools/refs/heads/main/freemobileIPv6.rsc";
            "path"="flash/mktools/freemobileIPv6.rsc"
        };
        {
            "url"="https://raw.githubusercontent.com/mwinandy/mikrotik-tools/refs/heads/main/functions.rsc";
            "path"="flash/mktools/functions.rsc"
        };
        {
            "url"="https://raw.githubusercontent.com/mwinandy/mikrotik-tools/refs/heads/main/backup.rsc";
            "path"="flash/mktools/backup.rsc"
            "script"="MkToolsBackup";
            "command"="import flash/mktools/backup.rsc;";
        };
        
    }
    
    :foreach script in=$scripts do={
        
        :local scriptPath ($script->"path");
        :local scriptUrl ($script->"url");
        :local scriptSource [$download $scriptUrl];
        :local scriptName ($script->"script");
        :local scriptCommand ($script->"command");
                
        :do {
            :put "Download: $scriptUrl to $scriptPath";

            :do {
                /file/remove $scriptPath
            } on-error={};
            
            /file/add type=file name=$scriptPath content=$scriptSource;
            
            :if ( [:len $scriptName ] != 0 ) do={
                
                :do {
                    /system/script/remove $scriptName
                } on-error={};
                
                /system/script/add name="$scriptName" source="$scriptCommand"
                
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
