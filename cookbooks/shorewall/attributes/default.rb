default[:shorewall][:enabled] = false

# zones ordered from most specific to most general
override[:shorewall][:zones] = [
	{ :zone => "fw", :type => "firewall" },
    { :zone => "lan", :type => "ipv4" },
    { :zone => "net", :type => "ipv4" }
]

override[:shorewall][:hosts] = []

override[:shorewall][:policy] = [
    { :source => "fw", :dest => "all", :policy => :ACCEPT },
    { :source => "net", :dest => "fw", :policy => :REJECT, :log => :DEBUG },
    { :source => "all", :dest => "all", :policy => :REJECT }
]

override[:shorewall][:interfaces] = [
    {:zone => 'net', :interface => "eth0", :broadcast => "detect", :options => "tcpflags,nosmurfs,logmartians,routefilter"},
    {:zone => 'lan', :interface => "eth1", :broadcast => "detect", :options => "tcpflags,nosmurfs,logmartians,routefilter"}
]

#override[:shorewall][:hosts] = node.default['shorewall']['interfaces']

override[:shorewall][:rules] = [
    { :description => "Incoming SSH to firewall",
      :source => "all", :dest => :fw, :proto => :tcp, :dest_port => 22, :action => :ACCEPT },
    { :description => "Ping",
      :source => "all", :dest => :fw, :proto => :icmp, :dest_port => "", :action => :ACCEPT },
    { :description => "DNS",
      :source => "all", :dest => :fw, :proto => "", :dest_port => "", :action => "DNS/ACCEPT" },
    { :description => "HTTP",
      :source => "all", :dest => :fw, :proto => "", :dest_port => "", :action => "HTTP/ACCEPT" },
    { :description => "HTTPS",
      :source => "all", :dest => :fw, :proto => "", :dest_port => "", :action => "HTTPS/ACCEPT" },
    { :description => "SMTP",
      :source => "all", :dest => :fw, :proto => "", :dest_port => "", :action => "SMTP/ACCEPT" },
    { :description => "SMTPS",
      :source => "all", :dest => :fw, :proto => "", :dest_port => "", :action => "SMTPS/ACCEPT" }
]

# vim: ai et sts=4 sw=4 ts=4
