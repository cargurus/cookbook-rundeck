Rundeck Cookbook
================

[![Build Status](https://travis-ci.org/sous-chefs/rundeck.svg?branch=master)](https://travis-ci.org/sous-chefs/rundeck)[![Cookbook Version](https://img.shields.io/cookbook/v/rundeck.svg)](https://supermarket.chef.io/cookbooks/rundeck)

Installs and configures Rundeck with an optional Apache reverse proxy. The cookbook has optional support for Active Directory and LDAP.

- [Chef Requirements](#chef-requirements)
- [Supported OS Versions](#supported-os-versions)
- [Resources](#resources)

Supported Chef Versions
-----------------------

- Chef 13
- Chef 14

Supported OS Versions
---------------------

The following platforms and versions are tested and supported using [test-kitchen](http://kitchen.ci/)

- Ubuntu 16.04 / 18.04
- Debian 9
- CentOS 6 / 7

Resources
---------
  
- [Apache (reverse-proxy)](https://github.com/sous-chefs/rundeck/blob/master/documentation/resource_apache.md)
- [Repository](https://github.com/sous-chefs/rundeck/blob/master/documentation/resource_repository.md)
- [Server_Install](https://github.com/sous-chefs/rundeck/blob/master/documentation/resource_server_install.md)