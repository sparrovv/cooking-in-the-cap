include_recipe "nginx"

package "libsqlite3-dev"

# nokogiri dependencies
package "libxslt-dev"
package "libxml2-dev"

node[:apps].each do |app|

  app_path = "/var/www/#{app[:name]}"
  sock     = "/tmp/sockets/#{app[:name]}.sock"

  app_directories = [
    "/tmp/sockets/",
    "/var/logs",
    "/var/logs/#{app[:name]}",
    "/var/pids",
    "#{app_path}",
    "#{app_path}/shared",
    "#{app_path}/shared/config",
    "#{app_path}/shared/system",
    "#{app_path}/shared/log",
    "#{app_path}/releases"
  ]

  app_directories.each do |dir|
    directory dir do
      owner node[:app_user]
      group node[:app_user]
      mode 0755
      recursive true
    end
  end

  template "/etc/nginx/sites-available/#{app[:name]}" do
    owner node[:app_user]
    mode 0644
    source "nginxsite.conf.erb"
    variables(
      :name       => app[:name],
      :servername => app[:servername],
      :sock       => sock,
      :root       => "#{app_path}/current/public"
    )
  end

  bash "enabling nginx site #{app[:name]}" do
    user "root"
    code "/usr/sbin/nxensite #{app[:name]}"
  end

  template "/etc/god/conf.d/#{app[:name]}.unicorn.god" do
    source "unicorn.god.erb"
    owner "root"
    group "root"
    mode 0755
    variables(
      :root => "#{app_path}/current",
      :name => "#{app[:name]}",
      :cmd  => "cd #{app_path}/current && bundle exec unicorn -c #{app_path}/current/config/unicorn.rb -E production -D",
      :pid  =>  "/var/pids/#{app[:name]}-unicorn.pid",
      :uid  => "#{node["app_user"]}",
      :gid  => "#{node["app_user"]}"
    )
  end

end
