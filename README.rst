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
      port: 8090
      home: /opt/jenkins
      user: jenkins
      group: www-data
