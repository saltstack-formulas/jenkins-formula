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

``jenkins.pkgrepo``
-----------------

Add and use the upstream jenkins-ci.org package repository instead of the default. (apt/yum only)

Pillar customizations:
==========================

.. code-block:: yaml

    jenkins:
      port: 8090
      home: /opt/jenkins
      user: jenkins
      group: www-data
