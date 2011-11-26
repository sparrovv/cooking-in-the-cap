name "ubuntu-server"
description "Basic Rails App Server"
run_list "recipe[shorewall]",
  "recipe[vim]",
  "recipe[git]",
  "recipe[curl]",
  "recipe[mysql]",
  "recipe[nginx]",
  "recipe[usefull_gems]",
  "recipe[god]"
