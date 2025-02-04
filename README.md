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
    :do {
        [/system/scheduler/remove "mkToolsFreemobileIPv6"];
    } on-error={};
    /system/scheduler/add name="mkToolsFreemobileIPv6" interval="0:0:30" on-event="import mktools/freemobileIPv6.rsc;";
}
```