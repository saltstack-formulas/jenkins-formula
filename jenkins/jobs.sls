include:
  - jenkins
  - jenkins.cli

{% from "jenkins/map.jinja" import jenkins with context %}
{% from 'jenkins/macros.jinja' import jenkins_cli with context %}

{% for job, path in jenkins.jobs.installed.iteritems() %}
jenkins_install_job_{{ job }}:
  cmd.run:
    - unless: {{ jenkins_cli('list-jobs') }} | grep {{ job }}
    - name: {{ jenkins_cli('create-job', job, '<', path) }}
    - timeout: 360
    - require:
      - service: jenkins
      - cmd: jenkins_updates_file
      - cmd: jenkins_cli_jar
{% endfor %}
