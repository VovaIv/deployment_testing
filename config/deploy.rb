lock "~> 3.20.0"

set :application, "deployment_testing"
set :repo_url, "git@github.com:VovaIv/deployment_testing.git"

set :deploy_to, "/home/ubuntu/deployment_testing"

set :rbenv_type, :user
set :rbenv_ruby, "3.2.1"

set :linked_files, fetch(:linked_files, []).push(
  "config/database.yml",
  "config/master.key"
)

set :linked_dirs, fetch(:linked_dirs, []).push(
  "log",
  "tmp/pids",
  "tmp/sockets",
  "public/system",
  "storage"
)

set :keep_releases, 5

set :puma_service_unit_name, "puma_simple_survey_tool"

set :branch, "main"

set :bundle_jobs, 1
