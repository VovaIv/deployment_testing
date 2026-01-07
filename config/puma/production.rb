directory "/home/ubuntu/deployment_testing"

environment "production"

pidfile "/home/ubuntu/deployment_testing/tmp/pids/puma.pid"
state_path "/home/ubuntu/deployment_testing/tmp/pids/puma.state"

bind "unix:///home/ubuntu/deployment_testing/tmp/sockets/puma.sock"

workers 2
threads 5, 5

preload_app!

stdout_redirect "log/puma.stdout.log", "log/puma.stderr.log", true