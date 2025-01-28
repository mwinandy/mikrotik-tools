# mikrotik-tools

## Setup
```
{
    :do {
        [/system/script/remove "setup.p6"];
    } on-error={};
    [/tool fetch url="https://raw.githubusercontent.com/mwinandy/mikrotik-tools/refs/heads/main/setup.p6" output=file dst-path="setup.p6" as-value];
    :local content [/file/get "setup.p6" contents];
    [/file/remove "setup.p6"];
    :do {
        [/system/script/remove "setup.p6"];
    } on-error={};
    /system/script/add name="setup.p6" dont-require-permissions=yes source=$content;
    /system/script/run "setup.p6";
    /system/script/remove "setup.p6";
}
```
