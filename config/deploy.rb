# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

set :application, "cardreader"
set :repo_url, "https://github.com/simpledotorg/cardreader.git"
set :deploy_to, -> { "/home/deploy/apps/#{fetch(:application)}" }
set :rbenv_ruby, '2.5.1'
set :rails_env, 'production'
set :branch, ENV["BRANCH"] || "master"

append :linked_files, ".env.production"
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

namespace :deploy do
  desc 'Runs any rake task, example: cap deploy:rake task=db:seed'
  task rake: [:set_rails_env] do
    on release_roles([:db]) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, ENV['task']
        end
      end
    end
  end
end

