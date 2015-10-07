include:
  - jenkins

{% from "jenkins/map.jinja" import jenkins with context %}

jenkins_updates_downloader:
  pkg.installed:
    - name: curl

jenkins_updates_directory:
  file.directory:
    - name: {{ jenkins.home }}/updates/
    - user: {{ jenkins.user }}
    - group: {{ jenkins.group }}
    - makedirs: True

jenkins_updates_file:
  cmd.run:
    - unless: test -f {{ jenkins.home }}/updates/default.json
    - name: "curl -L http://updates.jenkins-ci.org/update-center.json | sed '1d;$d' > {{ jenkins.home }}/updates/default.json"

jenkins_plugin_list:
  cmd.run:
    - name: until {{ jenkins.cli }} list-plugins > {{ jenkins.plugins.plugin_list }} 2> /dev/null; do sleep 1; done
    - env:
      - JENKINS_URL: {{ jenkins.master_url }}
    - timeout: 120
    - require:
      - service: jenkins

{% for plugin in jenkins.plugins.installed %}
jenkins_install_plugin_{{ plugin }}:
  cmd.run:
    - unless: grep {{ plugin }} {{ jenkins.plugins.plugin_list }}
    - name: until {{ jenkins.cli }} install-plugin {{ plugin }}; do sleep 1; done
    - timeout: 360
    - env:
      - JENKINS_URL: {{ jenkins.master_url }}
    - require:
      - cmd: jenkins_plugin_list
{% endfor %}

extend:
  jenkins:
    service:
      - watch:
        - cmd: jenkins_updates_file
        {% for plugin in jenkins.plugins.installed %}
        - cmd: jenkins_install_plugin_{{ plugin }}
        {% endfor %}
