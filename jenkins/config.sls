{% from "jenkins/map.jinja" import jenkins with context %}

create_ssh_directory_for_git_auth:
  file.directory:
    - name: /var/.ssh
    - user: {{ jenkins.user }}
    - group: {{ jenkins.group }}
    - mode: 755

deploy_private_key_for_git_auth:
  file.managed:
    # The private key is on jenkins-master
    - name: /var/.ssh/id_rsa
    # Set here the location of the pillar item where you have stored your key
    - contents_pillar: jenkins:master:private_key
    - user: {{ jenkins.user }}
    - group: {{ jenkins.group }}
    - mode: 600
    - require:
      - file: create_ssh_directory_for_git_auth

get_jenkins_config_from_git:
  git.latest:
    - name: {{ jenkins.jenkins_config_git_repo }}
    - target: {{ jenkins.home }}
    - rev: {{ jenkins.git_rev }}
    - branch: {{ jenkins.git_local_branch }}
    - force_clone: True
    - https_user: {{ jenkins.git_https_user }}
    - https_pass: {{ jenkins.git_https_pass }}
    - identity: {{ jenkins.git_ssh_key_uri }}
    - require:
      - file: deploy_private_key_for_git_auth
    - unless: git rev-parse --resolve-git-dir {{ jenkins.home }}/.git

change_file_ownership_of_JENKINS_HOME:
  file.directory:
    - name: {{ jenkins.home }}
    - user: {{ jenkins.user }}
    - group: {{ jenkins.group }}
    - recurse:
      - user
      - group
    - watch:
      - git: get_jenkins_config_from_git
    - unless: stat -c '%U' {{ jenkins.home }} | grep jenkins

restart_jenkins_when_config_changes:
  service.running:
    - name: jenkins
    - watch:
      - git: get_jenkins_config_from_git
      - file: change_file_ownership_of_JENKINS_HOME
