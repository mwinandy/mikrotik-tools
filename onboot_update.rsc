{
    #replace with internet detection;
    :delay 10000ms;
    :do {
        [/system/script/remove "setup.rsc"];
    } on-error={};
    [/tool fetch url="https://raw.githubusercontent.com/mwinandy/mikrotik-tools/refs/heads/main/setup.rsc" output=file dst-path="setup.rsc" as-value];
    :local content [/file/get "setup.rsc" contents];
    [/file/remove "setup.rsc"];
    :do {
        [/system/script/remove "setup.rsc"];
    } on-error={};
    /system/script/add name="setup.rsc" dont-require-permissions=yes source=$content;
    /system/script/run "setup.rsc";
    /system/script/remove "setup.rsc";
}