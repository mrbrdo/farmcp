require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rvm'
require 'mina-extras/puma'
require 'mina-extras/git'
require 'mina-extras/rvm'
require 'mina-extras/auto-repository'
require 'mina-extras/jruby-patch' if RUBY_PLATFORM == "java"

set :branch, current_git_branch!

case branch!
when 'something'
else
  set :user, 'user'
  set :deploy_to, "/home/user/farmcp"
  set :domain, "192.168.1.201"
  set :rails_env, 'production'
end

set :shared_paths, ['config/database.yml', 'log', '.env', 'public/assets']

task :environment do
  invoke :'rvm:use:current'
end

namespace :puma do
  task :config do
    cmd_prefix  = "cd #{deploy_to}/#{current_path} ; "
    cmd_prefix += "RAILS_ENV=#{rails_env!} NEW_RELIC_DISPATCHER=puma bundle exec"
    set :puma_start_cmd, "#{cmd_prefix} puma -C #{File.join(deploy_to,current_path,'config','puma.rb')}"
    set :puma_stop_cmd, "#{cmd_prefix} pumactl -S #{deploy_to}/#{shared_path}/sockets/puma.state stop"
    set :puma_restart_cmd, "#{cmd_prefix} pumactl -S #{deploy_to}/#{shared_path}/sockets/puma.state restart"
  end
end

task :setup => :environment do
  %w(config log repos sockets pids public/assets).each do |dir|
    queue! %[mkdir -p "#{deploy_to}/shared/#{dir}"]
    queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/#{dir}"]
  end

  queue! %[touch "#{deploy_to}/shared/config/database.yml"]
  queue  %[echo "-----> Be sure to edit 'shared/config/database.yml'."]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'

    to :launch do
      invoke :'puma:restart'
    end
  end
end
