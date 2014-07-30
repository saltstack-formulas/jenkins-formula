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

Add a jenkins nginx entry. 

Pillar customizations:
==========================

.. code-block:: yaml

    jenkins:
      port: 8090
      home: /opt/jenkins
      user: jenkins
      group: www-data
