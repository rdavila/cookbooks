user "www-data"  do
  comment "web apps user"
  system true
  shell "/bin/false"
  group "www-data"
end

script "install_nginx"  do
  creates '/opt/nginx/sbin/nginx'
  interpreter "bash"
  user "root"
  cwd "/tmp"
  code <<-EOH
  wget http://nginx.org/download/nginx-0.7.67.tar.gz
  tar -zxf nginx-0.7.67.tar.gz
  cd nginx-0.7.67
  ./configure --prefix=/opt/nginx
  make
  make install
  EOH
end

directory "/var/log/nginx" do
  owner "root"
  group "root"
  mode "0644"
  action :create
  not_if "test -d /var/log/nginx"
end

directory "/etc/nginx/vhosts" do
  owner "root"
  group "root"
  mode "0755"
  action :create
  recursive true
  not_if "test -d /etc/nginx/vhosts"
end

cookbook_file "/etc/nginx/nginx.conf" do
  owner "root"
  mode "0644"
  action :create_if_missing
end

cookbook_file "/etc/init.d/nginx" do
  source "nginx_init_script"
  owner "root"
  mode "0755"
  action :create_if_missing
end

cookbook_file "/etc/nginx/vhosts/default.vhost" do
  owner "root"
  mode "0644"
  action :create
end

service "apache" do
  case node[:platform]
  when "centos"
    service_name "httpd"
  else
    service_name "apache2"
  end
  action [ :stop, :disable ]
end

service "nginx"  do
  supports :status => true, :start => true, :stop => true, :restart => true, :reload => true
  action [ :enable, :restart ]
end
