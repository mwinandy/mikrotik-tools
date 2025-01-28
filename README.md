# mikrotik-tools

## Setup
```
{
    ([/tool fetch url="https://raw.githubusercontent.com/mwinandy/mikrotik-tools/refs/heads/main/setup.p6" output=file dst-path="fetch.temp" as-value]);
    :local content [/file/get "fetch.temp" contents];
    [/file/remove "fetch.temp"];
    :parse $content;
}
```
