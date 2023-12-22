# server check

You can check your server and make sure it is useful in all countries and the IP is white.

This bash script first of all installs Docker, Python, and other useful dependencies.

Then you should write your domain, and the system will start a removable nginx (nginx-server-test) and set your domain in nginx. After that, you should go to your registrar and set a record for your server IP in @ and www.

Then the script asks you about record setting, and if you set the record, you can answer yes and SSL will be generated for your domains.

After that, you can go to this site (https://check-host.net/) and write down your domain and check your server.

If you like this script, give it a big star.
