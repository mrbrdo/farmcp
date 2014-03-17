# FarmCP - Mining Farm management web-app

## Install

Tested on BAMT 1.3 with cgminer (or sgminer).

First install curl and git:

```
sudo apt-get install curl git
```

Now make sure you are not logged in as root (write `whoami`, it should not say root).
Write the following commands, one line at a time:

```
\curl -sSL https://get.rvm.io | bash -s stable
rvm install ruby-2.1.0

cd ~
git clone https://github.com/mrbrdo/farmcp.git
cd farmcp
bundle install
rvmsudo ruby script/install-init-d.rb
```

* Note: the first time you open it after installing, it can take **a few minutes** to open.
* Now you can open the web app at `http://YOUR_RIG_IP:8085/`

## Upgrade

```
sudo /etc/init.d/puma stop
cd ~
rm -rf farmcp

git clone https://github.com/mrbrdo/farmcp.git
cd farmcp
bundle install
rvmsudo ruby script/install-init-d.rb
```

## Configure

Edit or create a file in your home folder: `.farmcp`

**Example `~/.farmcp`:**

```json
{

"username" : "user",
"password" : "pass",
"port" : 8085,
"rigs" : [
  "192.168.1.2",
  "192.168.1.3:4055"
],
"names" : [
	"miner1",
	"miner2"
]
}
```

* username and password are optional, if you do not specify them, the web app will not be password protected.
* Specify rig IPs in "rigs", you can also specify a custom port if it is not the default 4028. The rigs need to have cgminer RPC enabled in cgminer.conf
* names are optional and you can also use hostnames like this:

```json
"rigs" : [
  "miner1",
  "miner2:4055"
]
```
if there is no 'names' section and only IP addresses are provided in 'rigs' section the dashboard will display "Rig #number" instead of rig name

**Tags**

```json
"tags" : [
  "mom",
  ["dad", "7950"]
]
```

You can display tags for the rig. Normally they are blue but if they contain only numbers (like GPU type), they're cyan.

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
sudo /etc/init.d/puma restart
```
