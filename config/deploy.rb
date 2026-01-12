lock "~> 3.20.0"

set :application, "deployment_testing"
set :repo_url, "git@github.com:VovaIv/deployment_testing.git"

# Deploy directory
set :deploy_to, "/home/ubuntu/deployment_testing"

# Ruby version
set :rbenv_type, :user
set :rbenv_ruby, "3.2.1"

# Shared files & directories (persist across deploys)
set :linked_files, fetch(:linked_files, []).push(
  "config/database.yml",
  "config/master.key"
)

set :linked_dirs, fetch(:linked_dirs, []).push(
  "log",
  "tmp/pids",
  "tmp/sockets",
  "storage",
  "public/system",
  "public/assets" # important for precompiled assets
)

# Keep only the last 5 releases
set :keep_releases, 5

# Branch to deploy
set :branch, "main"

# Puma config
set :puma_systemctl_user, :system
set :puma_service_unit_name, 'puma'

# Bundler
set :bundle_jobs, 1

# Rails master key
set :rails_master_key, ENV['RAILS_MASTER_KEY']

# Assets roles
set :assets_roles, [:web, :app]
