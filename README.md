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

Replace YOUR_USERNAME with your username (write `whoami` to find out, it should not be root).

* Note: the first time you open it after installing, it can take **a few minutes** to open.
* Now you can open the web app at `http://YOUR_RIG_IP:8085/`

## Start on boot

If you want FarmCP to start automatically when you reboot, edit the file `/etc/init/farmcp.conf`.

```
nano /etc/init/farmcp.conf
```

At the top of the file, add this line:

```
start on runlevel [2345]
```

That's it, now when you reboot, FarmCP will start automatically.

## Upgrade

```
cd ~/farmcp
git pull
bundle install
sudo /etc/init.d/puma restart
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
sudo /etc/init.d/puma restart
```
