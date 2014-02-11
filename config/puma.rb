#!/usr/bin/env puma
require 'json'
require File.expand_path('../../app/services/json_config', __FILE__)
deploy_dir = File.expand_path('../..', __FILE__)
port = JsonConfig.get['port'] || 8085

directory deploy_dir
environment 'production'

daemonize true

pidfile "#{deploy_dir}/log/puma.pid"
state_path "#{deploy_dir}/log/puma.state"
stdout_redirect "#{deploy_dir}/log/puma.out.log", "#{deploy_dir}/log/puma.err.log"

quiet

threads 1, 3

bind "tcp://0.0.0.0:#{port}"
activate_control_app "unix://#{deploy_dir}/log/pumactl.sock"
