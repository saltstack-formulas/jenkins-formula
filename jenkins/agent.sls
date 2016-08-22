{% from "jenkins/map.jinja" import jenkins with context %}

# This sls file is for the setup of Jenkins agent using normal jenkins sls
# but only sets up the correct configs rather than installing also the master
include:
  - jenkins

exclude:
  # Do not install Jenkins master
  - id: jenkins

# There is no need to setup known_hosts file since Jenkins can do that
# automatically itself.
create_ssh_directory_on_agent:
  file.directory:
    - name: {{ jenkins.home }}/.ssh
    - user: {{ jenkins.user }}
    - group: {{ jenkins.group }}
    - mode: 700

deploy_private_key_on_agent:
  file.managed:
    # The public key is on agent and in the file authorized_keys
    - name: {{ jenkins.home }}/.ssh/authorized_keys
    # Set here the location of the pillar item where you have stored your key
    - contents_pillar: jenkins:agent:public_key
    - user: {{ jenkins.user }}
    - group: {{ jenkins.group }}
    - mode: 640
    - require:
      - file: create_ssh_directory_on_agent

create_ssh_directory_for_git_auth_for_agents:
  file.directory:
    - name: /var/.ssh
    - user: {{ jenkins.user }}
    - group: {{ jenkins.group }}
    - mode: 755

deploy_private_key_for_git_auth_for_agents:
  file.managed:
    # The private key is on jenkins agents
    - name: /var/.ssh/id_rsa
    # Set here the location of the pillar item where you have stored your key
    - contents_pillar: jenkins:agent:private_key
    - user: {{ jenkins.user }}
    - group: {{ jenkins.group }}
    - mode: 600
    - require:
      - file: create_ssh_directory_for_git_auth_for_agents

deploy_private_key_on_agents:
  file.managed:
    # The private key is on an agent
    - name: {{ jenkins.home }}/.ssh/id_rsa
    # Set here the location of the pillar item where you have stored your key
    - contents_pillar: jenkins:agent:private_key
    - user: {{ jenkins.user }}
    - group: {{ jenkins.group }}
    - mode: 600
    - require:
      - file: deploy_private_key_for_git_auth_for_agents

set_known_host_for_git_login:
  file.managed:
    - name: {{ jenkins.home }}/.ssh/known_hosts
    - contents_pillar: jenkins:agent:known_hosts
    - user: {{ jenkins.user }}
    - group: {{ jenkins.group }}
    - mode: 600
    - require:
      - file: create_ssh_directory_for_git_auth_for_agents
