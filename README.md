# Install

Tested on BAMT 1.3 with cgminer (or sgminer).

```
sudo apt-get install curl

# DO NOT DO THE FOLLOWING AS ROOT
\curl -sSL https://get.rvm.io | bash -s stable
rvm install ruby-2.1.0

cd ~
git clone https://github.com/mrbrdo/farmcp.git
cd farmcp
bundle install
script/puma start
```

# Configure

Edit or create a file in your home folder: `.farmcp`

Example config:

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
* Specify rig IPs in "rigs", you can also specify a custom port if it is not the default 4028. The rigs need to have cgminer RPC enabled in cgminer.conf:

```
"api-listen" : true,
"api-network" : true,
"api-allow" : "W:192.168.1.0/24",
"api-port" : "4028",
```
