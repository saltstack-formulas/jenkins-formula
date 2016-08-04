{% from "jenkins/map.jinja" import jenkins with context %}

create_ssh_directory_on_master:
  file.directory:
    - name: {{ jenkins.home }}/.ssh
    - user: {{ jenkins.user }}
    - group: {{ jenkins.group }}
    - mode: 700

# This is just a static key, during production dynamic key generation is
# recommended
deploy_private_key_on_master:
  file.managed:
    # The private key is on master
    - name: {{ jenkins.home }}/.ssh/id_rsa
    # Set here the location of the pillar item where you have stored your key
    - contents_pillar: jenkins:master:private_key
    - user: {{ jenkins.user }}
    - group: {{ jenkins.group }}
    - mode: 700
    - require:
      - file: create_ssh_directory_on_master
