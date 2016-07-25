{% from "jenkins/map.jinja" import jenkins with context %}
{% import "jenkins/macros/cli_macro.jinja" as cli_macro %}

{% if grains['os_family'] == 'RedHat' %}
  {% set listening_tool = "curl" %}
{% else %}
  {% set listening_tool = jenkins.netcat_pkg %}
{% endif %}

check_if_jenkins_server_runs:
  cmd.run:
    - name: "until {{ cli_macro.jenkins_listen() }}; do sleep 1; done"

check_if_jenkins_serves_cli:
  cmd.run:
    - name: "until (curl -I -L {{ jenkins.master_url }}/jnlpJars/jenkins-cli.jar | grep \"Content-Type: application/java-archive\"); do sleep 1; done"
    - require:
      - cmd: check_if_jenkins_server_runs

# Download the Jenkins CLI jar file
download_jenkins_cli_jar:
  cmd.run:
    - name: "curl -L -o {{ jenkins.cli_path }} {{ jenkins.master_url }}/jnlpJars/jenkins-cli.jar"
    - require:
      - cmd: check_if_jenkins_serves_cli

login_to_jenkins_using_cli:
  cmd.run:
    - name: "java -jar {{ jenkins.cli_path }} -s {{ jenkins.master_url }} login --username {{ jenkins.admin_user }} --password {{ jenkins.admin_pw }}"
    - require:
      - cmd: download_jenkins_cli_jar

check_if_jenkins_cli_works:
  cmd.run:
    - name: "until {{ cli_macro.jenkins_cli('who-am-i') }}; do sleep 1; done"
    - require:
      - cmd: login_to_jenkins_using_cli
