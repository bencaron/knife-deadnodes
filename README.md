# knife-deadnodes

A plugin for Chef::Knife which displays nodes that are probably dead.

We define "dead" as :

* last seen by the server more than 24 hours ago
* node[:fqdn] does not resolve
* inode[:ipaddress] do not answer to ping

Of course, in your environment it's totally possible for a node to fail these tests and still be non-dead.

## Usage 


Ask for the list of dead nodes:

```
% knife node deadnodes 
FIXME give examples!
```

## Installation

#### Gem install

knife-deadnodes is available on rubygems.org - if you have that source in your gemrc, you can simply use:

    gem install knife-deadnodes

FIXME: this is false (for now!). Copy the plugins at the right places for now!
