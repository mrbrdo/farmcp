#!/usr/bin/env puma

deploy_dir = File.expand_path('../..', __FILE__)

directory deploy_dir
environment 'production'

daemonize true

pidfile "#{deploy_dir}/log/puma.pid"
state_path "#{deploy_dir}/log/puma.state"
stdout_redirect "#{deploy_dir}/log/puma.log", "#{deploy_dir}/log/puma.err.log"

quiet

threads 1, 3

bind "tcp://0.0.0.0:8080"
activate_control_app "unix://#{deploy_dir}/log/pumactl.sock"
