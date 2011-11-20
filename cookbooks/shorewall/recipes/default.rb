require 'set'

package "shorewall" do
  action :install
end

template "/etc/shorewall/hosts" do
  source "hosts.erb"
  mode 0600
  owner "root"
  group "root"
  notifies :restart, "service[shorewall]"
end

template "/etc/shorewall/interfaces" do
  source "interfaces.erb"
  mode 0600
  owner "root"
  group "root"
  notifies :restart, "service[shorewall]"
end

template "/etc/shorewall/policy" do
  source "policy.erb"
  mode 0600
  owner "root"
  group "root"
  notifies :restart, "service[shorewall]"
end

template "/etc/shorewall/rules" do
  source "rules.erb"
  mode 0600
  owner "root"
  group "root"
  notifies :restart, "service[shorewall]"
end

template "/etc/shorewall/zones" do
  source "zones.erb"
  mode 0600
  owner "root"
  group "root"
  notifies :restart, "service[shorewall]"
end

shorewall_enabled = [true, "true"].include?(node[:shorewall][:enabled])
if shorewall_enabled
  template "/etc/shorewall/shorewall.conf"
end

service "shorewall" do
  supports [ :status, :restart ]
  if shorewall_enabled
    action [:start, :enable]
  end
end

# vim: ai et sts=2 sw=2 sts=2
