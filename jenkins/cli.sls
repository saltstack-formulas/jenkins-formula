{% from "jenkins/map.jinja" import jenkins with context %}
{% import "jenkins/macros/cli_macro.jinja" as cli_macro %}

{% set timeout = 360 %}
{% if grains['os_family'] == 'RedHat' %}
  {% set listening_tool = "curl" %}
{% else %}
  {% set listening_tool = jenkins.netcat_pkg %}
{% endif %}

jenkins_listening:
  pkg.installed:
    - name: listening_tool
  cmd.wait:
    - name: "until {{ cli_macro.jenkins_listen() }}; do sleep 1; done"
    - timeout: 10
    - require:
      - service: jenkins
    - watch:
      - service: jenkins

jenkins_serving:
  pkg.installed:
    - name: curl

  cmd.wait:
    - name: "until (curl -I -L {{ jenkins.master_url }}/jnlpJars/jenkins-cli.jar | grep \"Content-Type: application/java-archive\"); do sleep 1; done"
    - timeout: {{ timeout }}
    - watch:
      - cmd: jenkins_listening

jenkins_cli_jar:
  pkg.installed:
    - name: curl

  cmd.run:
    - unless: test -f {{ jenkins.cli_path }}
    - name: "curl -L -o {{ jenkins.cli_path }} {{ jenkins.master_url }}/jnlpJars/jenkins-cli.jar"
    - require:
      - pkg: jenkins_cli_jar
      - cmd: jenkins_serving

jenkins_responding:
  cmd.wait:
    - name: "until {{ cli_macro.jenkins_cli('who-am-i') }}; do sleep 1; done"
    - timeout: {{ timeout }}
    - watch:
      - cmd: jenkins_cli_jar

restart_jenkins:
  cmd.wait:
    - name: {{ cli_macro.jenkins_cli('safe-restart') }}
    - require:
      - cmd: jenkins_responding

reload_jenkins_config:
  cmd.wait:
    - name: {{ cli_macro.jenkins_cli('reload-configuration') }}
    - require:
      - cmd: jenkins_responding
