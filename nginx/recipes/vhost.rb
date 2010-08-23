# Create vhost file

node[:non_rails_apps].each do |app|
  user app[:username] do
    home  "/var/www/vhosts/#{app[:app_name]}"
    shell "/bin/bash"
    gid   "www-data"
  end

  directory "/var/www/vhosts/#{app[:app_name]}" do
    owner app[:username]
    group "www-data"
    recursive true
    not_if "test -d /var/www/vhosts/#{app[:app_name]}"
  end

  template "/etc/nginx/vhosts/#{app[:app_name]}.vhost" do
    source "vhost.conf.erb"
    variables({
      :app_name => app[:app_name]
    })
    not_if "test -f /etc/nginx/vhosts/#{app[:app_name]}.vhost"
  end

end
