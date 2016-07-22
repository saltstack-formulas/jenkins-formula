jenkins
=======

Available states
================

.. contents::
    :local:

``jenkins``
-----------

Install jenkins from the source package repositories and start it up.

``jenkins.nginx``
-----------------

Add a jenkins nginx entry. It depends on the nginx formula being installed and
requires manual inclusion `nginx` and `jenkins` states in your `top.sls` to
function, in this order: `jenkins`, `nginx`, `jenkins.nginx`.

Pillar customizations:
==========================

.. code-block:: yaml

    jenkins:
      lookup:
        port: 80
        home: /usr/local/jenkins
        user: jenkins
        group: www-data
        server_name: ci.example.com

Concerning the file cli.sls
===========================

Due to differences in the scope of functionality of netcat between RedHat and Debian/other Linux distributions, nc -z does not work on RedHat since the option -z simply does not exist. Hence by default, RedHat distro will use curl instead. If you are on Debian distro, please feel free to use a custom versin of netcat. You can define that in your pillar file as netcat_pkg: your_nc_package.

Contributing to This Project
============================

1. Fork this repository.
2. If you need to include this repo in a git superproject, then make your fork a git submodule.
3. Submit Pull Request when you have developed a new feature or made a fix.
