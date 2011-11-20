package "mysql-server" do
  package_name value_for_platform(
    ["ubuntu", "debian"] => { "default" => "mysql-server" },
    ["redhat"] => { "default" => "mysql-server" }
  )
end

package "mysql-dev" do
  package_name value_for_platform(
    ["ubuntu", "debian"] => { "default" => "libmysqlclient-dev" },
    ["redhat"] => { "default" => "mysql-devel" }
  )
end

if platform? "redhat"
  service "mysqld" do
    supports :restart => true, :reload => true, :status => true
    action [ :enable, :start ]
  end
else
  service "mysql" do
    supports :restart => true, :reload => true, :status => true
    action [ :enable, :start ]
  end
end

execute "assign-root-password" do
  command "/usr/bin/mysqladmin -u root password \"#{node['mysql']['server_root_password']}\""
  action :run
  only_if "/usr/bin/mysql -u root -e 'show databases;'"
end

