# Create vhost file
# Create monit config 
# View possible to create unicorn config

unless test(?f, "/etc/init.d/unicorn")
  cookbook_file "/etc/init.d/unicorn" do
    source "unicorn_init_script"
    mode "0755"
  end

  directory "/etc/unicorn" do
    owner "root"
    group "root"
  end

  service "unicorn" do
    supports :start => true, :stop => true, :restart => true
    action :enable
  end
end

node[:applications].each do |app|
  user app[:username] do
    home "/var/www/vhosts/#{app[:username]}"
    shell "/bin/bash"
  end

  directory "/var/www/vhosts/#{app[:app_name]}" do
    owner app[:username]
    group app[:username]
    recursive true
    not_if "test -d /var/www/vhosts/#{app[:app_name]}"
  end

  template "/etc/nginx/vhosts/#{app[:app_name]}.vhost" do
    source "nginx_vhost.conf.erb"
    variables({
      :app_name => app[:app_name]
    })
    not_if "test -f /etc/nginx/vhosts/#{app[:app_name]}.vhost"
  end

  template "/etc/unicorn/#{app[:app_name]}.conf" do
    source "unicorn_app.conf.erb"
    mode "0644"
    variables({
      :app_name => app[:app_name],
      :environment => app[:env] || 'production'
    })
    not_if "test -f /etc/unicorn/#{app[:app_name]}.conf"
  end

  monit_unicorn = "/etc/monit.d/unicorn_#{app[:env] || 'production'}_#{app[:app_name]}"
  template monit_unicorn do
    source "unicorn_monit.erb"
    mode "0644"
    variables({
      :app_name => app[:app_name],
      :environment => app[:env] || 'production'
    })
    not_if "test -f #{monit_unicorn}"
  end
end
