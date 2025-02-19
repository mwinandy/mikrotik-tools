{

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

            :if ( [:len [/file/find where (name=$scriptPath)]] = 0 ) do={
                    /file/add type=file name=$scriptPath content=$scriptSource;
            } else={
                    /file/set $scriptPath contents=$scriptSource;
            }

            :if ( [:len $scriptName ] != 0 ) do={
                :if ( [:len [/system/script/find where (name=$scriptName)]] != 0 ) do={
                    /system/script/set $scriptName source="$scriptCommand";
                } else={
                    /system/script/add name="$scriptName" source="$scriptCommand"
                }
            };
            
        } on-error={
            :put "Fail: $scriptName"
        }

    };

    :if ( [:len [/system/scheduler/find where (name="mkToolsOnbootUpdate")]] = 0 ) do={
        /system/scheduler/add name="mkToolsOnbootUpdate";
    };

    /system/scheduler/set mkToolsOnbootUpdate start-time=startup interval="0:15:0" on-event="import flash/mktools/onboot_update.rsc;";
}
