directory "/home/ubuntu/deployment_testing/current"
environment "production"

pidfile "/home/ubuntu/deployment_testing/current/tmp/pids/puma.pid"
state_path "/home/ubuntu/deployment_testing/current/tmp/pids/puma.state"

bind "unix:///home/ubuntu/deployment_testing/current/tmp/sockets/puma.sock"

workers 2
threads 5, 5

preload_app!

stdout_redirect "log/puma.stdout.log", "log/puma.stderr.log", true