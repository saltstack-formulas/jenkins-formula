{% from "jenkins/map.jinja" import jenkins with context %}

{%- macro fmtarg(prefix, value)-%}
{{ (prefix + ' ' + value) if value else '' }}
{%- endmacro -%}
{%- macro jenkins_cli(cmd) -%}
{{ ' '.join(['java', '-jar', jenkins.cli_path, '-s', jenkins.master_url, fmtarg('-i', jenkins.get('privkey')), cmd]) }} {{ ' '.join(varargs) }}
{%- endmacro -%}

{% set timeout = 360 %}

jenkins_listening:
  pkg.installed:
    - name: {{ jenkins.netcat_pkg }}
  cmd.wait:
    - name: "until nc -z localhost {{ jenkins.jenkins_port }}; do sleep 1; done"
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
    - name: "until {{ jenkins_cli('who-am-i') }}; do sleep 1; done"
    - timeout: {{ timeout }}
    - watch:
      - cmd: jenkins_cli_jar
