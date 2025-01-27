{

    :global getCloudIP do={

        :return [/ip/cloud/get public-address];

    };

    :global getCloudIPv6 do={

        :return [/ip/cloud/get public-address-ipv6];

    };

}