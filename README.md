# BGPStream_Operate_Plugin

## What is this repertory?

BGPStream is a tool to handle the bgp data which created bg CAIDA, and its Bgpcorsaro module can define some customized plugins.

However, the procedure of creating or deleting a plugin is so complex that if one of the you make a mistake, everything will go wrong.

In the consideration of this problem, I write two shell scripts to help people create or delete the bgpcorsaro's plugin with only one shell command. That's really convinient!

## What is the BGPStream's version?

I provide the right version of BGPStream I have tested in the github repertory, you need to install the "wandio-4.0.0.tar.gz" and the "bgpstream-1.2.1.tar.gz". To see how to install and config it, see the [CAIDA's instruction](http://bgpstream.caida.org/docs/install/bgpstream).

## Where to put it?

Put the create_plg.sh, delete_plg.sh, bgpcorsaro_template.c and bgpcorsaro_template.h in the root directory of the bgpstream you uncompressed.

## How to use it?

1. create a new plugin
```
bash create_plg.sh <--Your Module Name(in low case)-->
```
2. delete an existed plugin
```
bash delete_plg.sh <--Your Module Name(in low case)-->
```

Example:

```
bash create_plg.sh test
bash delete_plg.sh test
```
