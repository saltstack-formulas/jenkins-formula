{% from "jenkins/map.jinja" import jenkins with context %}
include:
  - jenkins

get_jenkins_config_from_git:
  git.latest:
    - name: {{ jenkins.jenkins_config_git_repo }}
    - target: {{ jenkins.home }}
    - force_clone: True
    - require:
      - sls: jenkins

change_file_ownership_of_JENKINS_HOME:
  file.directory:
    - name: {{ jenkins.home }}
    - user: {{ jenkins.user }}
    - group: {{ jenkins.group }}
    - recurse:
      - user
      - group
    - require:
      - git: get_jenkins_config_from_git

restart_jenkins_with_systemctl:
  cmd.run:
    - name: "systemctl restart jenkins"
    - watch:
      - file: change_file_ownership_of_JENKINS_HOME
