This script was written to help pull data from the WAS-110 and insert it into node_exporter textfile exports for Prometheus to consume.

Steps:

* Requires SSH key to be added to the WAS-110 so you will need to generate one and place it on the authorized_keys file on the WAS-110.
     * You can do this by doing an ssh-keygen as root with no password
     * Copy the new key from ~/.ssh/id_*, not the one ending in .pub, to the ~/.ssh/authorized_keys file on the WAS-110.
* Install the OPNsense os-git-backup package from the System->Firmware->Plugins section. This will provide you the git binary on your install.
* Go to the /root directory and run ```git clone https://github.com/pyrodex/was-110-opn-stats.git``` and it will pull the code down into /root/was-110-opn-stats directory.
* Copy the actions_was110.conf to /usr/local/opnsense/service/conf/actions.d directory on your firewall 
* You'll need to restart the configd service (service configd restart)
* Now you can navigate to the OPNsense UI and go to System->Settings->Cron and add the WAS-110 job via the drop down for the time you prefer.

![alt text](https://github.com/pyrodex/was-110-opn-stats/blob/main/opnsense-cron.png?raw=true)

* Now you can validate the cron is running by monitoring the /var/log/was-110-stats.log file.

There is a provided Grafana dashboard provided and can be loaded.

Enjoy!
