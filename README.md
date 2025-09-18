This script was written to help pull data from the WAS-110 and insert it into node_exporter textfile exports for Prometheus to consume.

Assumptions:

* You are running OPNsense
* You are running 2.8.2+ on the WAS-110
* You have Prometheus
* You have install the OPNsense os-node_exporter plugin
* You have install the OPNsense os-git-backup plugin

Steps:

* With the release of WAS-110 firmware 2.8.2+ this now supports the native metrics page, this will NOT work unless you module is running 2.8.2+ code base.
* Go to the /root directory and run ```git clone https://github.com/pyrodex/was-110-opn-stats.git``` and it will pull the code down into /root/was-110-opn-stats directory.
* Copy the actions_was110.conf to /usr/local/opnsense/service/conf/actions.d directory on your firewall 
* You'll need to restart the configd service (service configd restart)
* Now you can navigate to the OPNsense UI and go to System->Settings->Cron and add the WAS-110 job via the drop down for the time you prefer.

![alt text](https://github.com/pyrodex/was-110-opn-stats/blob/main/opnsense-cron.png?raw=true)

* Now you can validate the cron is running by monitoring the /var/log/was-110-stats.log file.

There is a provided Grafana dashboard provided and can be loaded.

Enjoy!
