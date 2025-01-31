{
    :do {
        [/system/script/remove "mktools-setup.rsc"];
    } on-error={};
    [/tool fetch url="https://raw.githubusercontent.com/mwinandy/mikrotik-tools/refs/heads/main/setup.rsc" output=file dst-path="mktools-setup.rsc" as-value];
    :local content [/file/get "mktools-setup.rsc" contents];
    [/file/remove "mktools-setup.rsc"];
    :do {
        [/system/script/remove "mktools-setup.rsc"];
    } on-error={};
    /system/script/add name="mktools-setup.rsc" dont-require-permissions=yes source=$content;
    /system/script/run "mktools-setup.rsc";
    /system/script/remove "mktools-setup.rsc";
}