{% from "jenkins/map.jinja" import jenkins with context %}

# This sls file is for the setup of Jenkins agent using normal jenkins sls
# but only sets up the correct configs rather than installing also the master
include:
  - jenkins

exclude:
  # Do not install Jenkins master
  - id: jenkins
