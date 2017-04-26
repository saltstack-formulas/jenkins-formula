describe service('jenkins') do
  it { should be_enabled }
  it { should be_running }
end

describe service('nginx') do
  it { should be_enabled }
  it { should be_running }
end

describe command('curl -s -u admin:$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword) -o /dev/null -w "%{http_code}" http://localhost:8080') do
  its(:stdout) { should eq("200") }
  its(:stderr) { should be_empty }
end
