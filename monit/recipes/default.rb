case node[:platform]

when 'centos'
  yum_package "monit" do
    action :install
  end

  cookbook_file "/etc/monit.conf" do
    source "monit.conf"
    mode "0700"
  end
when 'ubuntu', 'debian'
  apt_package "monit" do
    action :install
  end

  cookbook_file "/etc/default/monit" do
    mode "0644"
  end

  cookbook_file "/etc/monit/monitrc" do
    source "monit.conf"
    mode "0644"
  end
  
end

directory "/etc/monit.d"

service "monit"  do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :restart ]
end
