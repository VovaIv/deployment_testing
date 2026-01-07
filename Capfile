require "capistrano/setup"
require "capistrano/deploy"

require "capistrano/rails"
require "capistrano/rails/assets"
require "capistrano/rails/migrations"

require "capistrano/bundler"
require "capistrano/rbenv"
require "capistrano/puma"
install_plugin Capistrano::Puma
install_plugin Capistrano::Puma::Systemd

Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }