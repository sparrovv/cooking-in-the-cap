### cooking with the cap - bootstraping ubuntu server with chef and capistrano

## This is a simple solution for bootstraping servers with capistrano and chef

The main purpose: setup simple rails ubuntu-server in less than 10min.

This is still in progress.

### Packages:
* nginx
* git
* unicorn
* god
* mysql
* shorewall
* vim

### Additionally it install some usefull gems, and you can setup directories for your app
* usefull gems
* application setup

### This also has to bootstrap my new node, so it should:

* create user - use config/user.yml file - creates user, and uploads publick key to the server. At the moment you need to login as root, and set password for this user manually, by passwd

`
cap chef:create_user user@host
`

* install ruby-1.9.2

`
cap chef:install_ruby192 user@host
`

* install chef-solo

`
cap chef:install_chef user@host
`

* upload cookbooks

`
cap chef:install_cookbook_repo node user@host
`

* run chef-solo

`
cap chef:solo node user@host
`

### TODO
* Setting password should be made cap
* Restart services when - templates changed.
* Add vimrc file

## Extra Information

Capistrano file was inspired and partly taken from https://github.com/mikesmullin/Chef-Solo-Capistrano-Bootstrap - I've made some changes, that fits better for my needs.
