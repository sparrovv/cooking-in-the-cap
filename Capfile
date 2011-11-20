#
# Chef-Solo Capistrano Bootstrap
#
# usage:
#   cap chef:bootstrap <dna> <remote_host>
#
# NOTICE OF LICENSE
#
# Copyright (c) 2010 Mike Smullin <mike@smullindesign.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# configuration
default_run_options[:pty] = true # fix to display interactive password prompts

target = ARGV[-1].split(':')
if (u = ARGV[-1].split('@')[-2])
  set(:user, u)
end
role :target, target[0]
set :port, target[1] || 22
cwd = File.expand_path(File.dirname(__FILE__))
cookbook_dir = '/var/chef-solo'
dna_dir = '/etc/chef'
node = ARGV[-2]

require 'yaml'

file = File.expand_path(File.dirname(__FILE__)) + '/config/user.yml'
config = YAML.load(File.read(file))

namespace :chef do

  task :prepare, roles: :target do
    install_cookbook_repo
    install_dna
    solo
  end

  desc "Install Ruby 1.9.2-p290 from sources"
  task :install_ruby192, roles: :target do
    ruby_version = 'ruby-1.9.2-p290'
    path = '/tmp'
    temp_path = path + "/" + ruby_version

    sudo 'apt-get update'
    sudo 'apt-get -y upgrade'
    sudo 'apt-get install -y build-essential wget zlib1g-dev libssl-dev libffi-dev'
    run "cd #{path} && wget ftp://ftp.ruby-lang.org//pub/ruby/1.9/ruby-1.9.2-p290.tar.bz2 && tar xjf ruby-1.9.2-p290.tar.bz2"

    bash_sudo "cd #{temp_path} && ./configure && make && make install"
    bash_sudo "cd #{temp_path}/ext/openssl/ && ruby extconf.rb && make && make install"
    bash_sudo "cd #{temp_path}/ext/readline/ && ruby extconf.rb && make && make install"
  end

  desc "Install Chef and Ohai gems as root"
  task :install_chef, roles: :target do
    sudo_env 'gem source -a http://gems.opscode.com/'
    sudo_env 'gem install ohai chef --no-ri --no-rdoc'
  end

  desc "Install Cookbook Repository from cwd"
  task :install_cookbook_repo, roles: :target do
    sudo 'aptitude install -y rsync'
    sudo "mkdir -m 0775 -p #{cookbook_dir}"
    sudo "chown #{config['user_name']} #{cookbook_dir}"
    reinstall_cookbook_repo
  end

  desc "Re-install Cookbook Repository from cwd"
  task :reinstall_cookbook_repo, roles: :target do
    rsync cwd + '/', cookbook_dir
  end

  desc "Install ./dna/*.json for specified node"
  task :install_dna, roles: :target do
    sudo 'aptitude install -y rsync'
    sudo "mkdir -m 0775 -p #{dna_dir}"
    sudo "chown #{config['user_name']} #{dna_dir}"
    put %Q(file_cache_path "#{cookbook_dir}"
    cookbook_path ["#{cookbook_dir}/cookbooks", "#{cookbook_dir}/site-cookbooks"]
    role_path "#{cookbook_dir}/roles"), "#{dna_dir}/solo.rb", via: :scp, mode: "0644"
    reinstall_dna
  end

  desc "Re-install ./dna/*.json for specified node"
  task :reinstall_dna, roles: :target do
    rsync "#{cwd}/dna/#{node}.json", "#{dna_dir}/dna.json"
  end

  desc "Execute Chef-Solo"
  task :solo, roles: :target do
    sudo_env "chef-solo -c #{dna_dir}/solo.rb -j #{dna_dir}/dna.json -l debug"

    exit # subsequent args are not tasks to be run
  end

  desc "Reinstall and Execute Chef-Solo"
  task :resolo, roles: :target do
    reinstall_cookbook_repo
    reinstall_dna
    solo
  end

  desc "Cleanup, Reinstall, and Execute Chef-Solo"
  task :clean_solo, roles: :target do
    cleanup
    install_chef
    install_cookbook_repo
    install_dna
    solo
  end

  desc "Remove all traces of Chef"
  task :cleanup, roles: :target do
    sudo "rm -rf #{dna_dir} #{cookbook_dir}"
    sudo_env 'gem uninstall -ax chef ohai'
  end
end


# helpers
def create_user(user, pass, group, groups, pubkey)
  sudo "groupadd #{user}; exit 0"
  sudo "useradd -s /bin/bash -m -g #{group} -G #{groups},#{user} #{user}"
  # setting password by useradd doesn't work form, couldn't find the reason of that...
  # also I can't use passwd, cause there is no --stdin option in ubuntu version.
  # after creating user I need to login to machine run it manually, this sucks...
  #sudo "passwd #{user}"
  ssh_dir = "/home/#{user}/.ssh"
  bash_sudo "mkdir -pm700 #{ssh_dir} && touch #{ssh_dir}/authorized_keys && chmod 600 #{ssh_dir}/authorized_keys && echo '#{pubkey}' >> #{ssh_dir}/authorized_keys && chown -R #{user}.#{group} #{ssh_dir}"
  bash_sudo "sed -ir 's/^\\(AllowUsers\\s\\+.\\+\\)$/\\1 #{user}/' /etc/ssh/sshd_config"
  sudo 'service ssh restart'
end

def sudo_env(cmd)
  run "#{sudo} -i #{cmd}"
end

def msudo(cmds)
  cmds.each do |cmd|
    sudo cmd
  end
end

def mrun(cmds)
  cmds.each do |cmd|
    run cmd
  end
end

def rsync(from, to)
  find_servers_for_task(current_task).each do |server|
    puts `rsync -avz -e "ssh -p#{port}" "#{from}" "#{server}:#{to}" \
      --exclude ".svn" --exclude ".git" --exclude "Capfile"`
  end
end

def bash(cmd)
  run %Q(echo "#{cmd}" > /tmp/bash)
  run "sh /tmp/bash"
  run "rm /tmp/bash"
end

def bash_sudo(cmd)
  run %Q(echo "#{cmd}" > /tmp/bash)
  sudo_env "sh /tmp/bash"
  run "rm /tmp/bash"
end
