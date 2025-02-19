# mikrotik-tools

## Setup
```
{
    [/tool fetch url="https://raw.githubusercontent.com/mwinandy/mikrotik-tools/refs/heads/main/setup.rsc" output=file dst-path="mktools-setup.rsc" as-value];
    import mktools-setup.rsc;
    /file/remove mktools-setup.rsc;
}
```

## FreemobileIPv6
```
{
    :if ( [:len [/system/scheduler/find where (name="mkToolsFreemobileIPv6")]] = 0 ) do={
        /system/scheduler/add name="mkToolsFreemobileIPv6";
    };
    /system/scheduler/set mkToolsFreemobileIPv6 interval="0:0:30" on-event="import flash/mktools/freemobileIPv6.rsc;";
}
```
