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
