jenkins
=======

jenkins
-------

Install jenkins from the source package repositories and start it up.

jenkins.nginx
-------------

Add a jenkins nginx entry. 

pillar customizations available:

.. code-block:: yaml

    jenkins:
      port: 8090
      home: /opt/jenkins
      user: jenkins
      group: www-data
