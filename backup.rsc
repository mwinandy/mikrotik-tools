{
    [import flash/mktools/functions.rsc];
    :global mkToolsEnvBackupTo;
    :global mkToolsWaitInternet;
    
    [$mkToolsWaitInternet];

    :local sysname [/system identity get name]
    :local textfilename
    :local backupfilename
    :local Version [/system resource get version]

    /system clock
    :local vtime [get time]
    :local vdate [get date]
    :local M ([:find "xxanebarprayunulugepctovecANEBARPRAYUNULUGEPCTOVEC" [:pick $vdate 1 3] -1] / 2); :if ($M>12) do={:set M ($M - 12)}
    :local MM [:pick (100 + $M) 1 3]
    # format DDMMYYYY-HHMMSS
    :local mydatetime ( [:pick $vdate 4 6].$MM.[:pick $vdate 7 11]."-".[:pick $vtime 0 2].[:pick $vtime 3 5].[:pick $vtime 6 8] )

    :set textfilename ($"mydatetime" . "-" . $"sysname" . ".rsc")
    :set backupfilename ($"mydatetime" . "-" . $"sysname" . ".backup")

    # backup action
    :if ($Version~"^7") do={
    :execute [/export file=$"textfilename" show-sensitive]
    } else={
    :execute [/export file=$"textfilename"]
    }
    :execute [/system backup save name=$"backupfilename"]

    # START Send Email .RSC
    /tool e-mail send to="$mkToolsEnvBackupTo" subject="[Backup] $sysname $mydatetime" body="Backup *.rsc OK" file="$textfilename";
    # END Send Email .RSC

    :delay 2s

    # START Send Email .BACKUP
    /tool e-mail send to="$mkToolsEnvBackupTo" subject="[Backup] $sysname $mydatetime" body="Backup *.backup OK" file="$backupfilename";
    # END Send Email .BACKUP

    # Remove local backups
    :delay 10s
    /file remove $textfilename
    /file remove $backupfilename

    :log info "Backups OK"

}