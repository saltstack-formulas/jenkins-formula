{% from "jenkins/map.jinja" import jenkins with context %}

include:
  - jenkins

exclude:
  - id: jenkins
