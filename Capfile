require "capistrano/setup"
require "capistrano/deploy"

# Git
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

# Rails
require "capistrano/rails"
require "capistrano/rails/assets"
require "capistrano/rails/migrations"

# Ruby / Bundler
require "capistrano/bundler"
require "capistrano/rbenv"

# Puma (systemd)
install_plugin Capistrano::Puma
install_plugin Capistrano::Puma::Systemd

# Custom tasks
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
