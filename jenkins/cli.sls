{% from "jenkins/map.jinja" import jenkins with context %}
{% import "jenkins/macros/cli_macro.jinja" as cli_macro %}

{% if grains['os_family'] == 'RedHat' %}
  {% set listening_tool = "curl" %}
{% else %}
  {% set listening_tool = jenkins.netcat_pkg %}
{% endif %}

# Always check if jenkins server is running when applying
# this sls state to the server on a scheduled basis.
# If there is an error, then an appropriate response can be implemented.
check_if_jenkins_server_runs:
  cmd.run:
    - name: "until {{ cli_macro.jenkins_listen() }}; do sleep 1; done"

# Trivial checks should always run.
check_if_jenkins_serves_cli:
  cmd.run:
    - name: "until (curl -I -L {{ jenkins.master_url }}/jnlpJars/jenkins-cli.jar | grep \"Content-Type: application/java-archive\"); do sleep 1; done"
    - require:
      - cmd: check_if_jenkins_server_runs

# Download the Jenkins CLI jar file unless it is already downloaded
download_jenkins_cli_jar:
  cmd.run:
    - name: "curl -L -o {{ jenkins.cli_path }} {{ jenkins.master_url }}/jnlpJars/jenkins-cli.jar"
    - require:
      - cmd: check_if_jenkins_serves_cli
    - unless: test -e /var/cache/jenkins/jenkins-cli.jar

# Login does not take up too much resources and should always run.
login_to_jenkins_using_cli:
  cmd.run:
    - name: "java -jar {{ jenkins.cli_path }} -s {{ jenkins.master_url }} login --username {{ jenkins.admin_user }} --password {{ jenkins.admin_pw }}"
    - require:
      - cmd: download_jenkins_cli_jar

# Another trivial check.
check_if_jenkins_cli_works:
  cmd.run:
    - name: "until {{ cli_macro.jenkins_cli('who-am-i') }}; do sleep 1; done"
    - require:
      - cmd: login_to_jenkins_using_cli
