{% from "jenkins/map.jinja" import jenkins with context %}
{% from 'jenkins/macros.jinja' import jenkins_cli with context %}

{% set timeout = 360 %}

jenkins_listening:
  pkg.installed:
    - name: {{ jenkins.netcat_pkg }}
  cmd.wait:
    - name: "until nc {{ jenkins.netcat_flag }} localhost {{ jenkins.jenkins_port }}; do sleep 1; done"
    - timeout: {{ jenkins.cli_timeout }}
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
  cmd.run:
    - unless: test -f {{ jenkins.cli_path }}
    - name: "curl -L -o {{ jenkins.cli_path }} {{ jenkins.master_url }}/jnlpJars/jenkins-cli.jar"
    - require:
      - cmd: jenkins_serving

restart_jenkins:
  cmd.wait:
    - name: {{ jenkins_cli('safe-restart') }}
    - require:
      - cmd: jenkins_cli_jar

reload_jenkins_config:
  cmd.wait:
    - name: {{ jenkins_cli('reload-configuration') }}
    - require:
      - cmd: jenkins_cli_jar

jenkins_responding:
  cmd.wait:
    - name: "until {{ jenkins_cli('who-am-i') }}; do sleep 1; done"
    - timeout: {{ timeout }}
    - watch:
      - cmd: jenkins_cli_jar
    - require: 
      - cmd: reload_jenkins_config
      - cmd: restart_jenkins


