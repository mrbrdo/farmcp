# FarmCP - Mining Farm management web-app

## Install

Tested on BAMT 1.3 with cgminer (or sgminer).

```
sudo apt-get install curl

# DO NOT DO THE FOLLOWING AS ROOT (i.e. do not use sudo)

\curl -sSL https://get.rvm.io | bash -s stable
rvm install ruby-2.1.0

cd ~
git clone https://github.com/mrbrdo/farmcp.git
cd farmcp
bundle install
script/puma start
```

Now you can open the web app at http://YOUR-RIG-IP:8080/

## Configure

Edit or create a file in your home folder: `.farmcp`

**Example `~/.farmcp`:**

```json
{

"username" : "user",
"password" : "pass",
"rigs" : [
  "192.168.1.2",
  "192.168.1.3:4055"
]

}
```

* username and password are optional, if you do not specify them, the web app will not be password protected.
* Specify rig IPs in "rigs", you can also specify a custom port if it is not the default 4028. The rigs need to have cgminer RPC enabled in cgminer.conf

**Cgminer config:**

Replace 192.168.1.0 with your LAN, for example if your rig IP is 192.168.0.10, use 192.168.0.0:

```
"api-listen" : true,
"api-network" : true,
"api-allow" : "W:192.168.1.0/24",
"api-port" : "4028",
```

After you change the config, restart the app:

```
cd ~/farmcp
script/puma restart
```
