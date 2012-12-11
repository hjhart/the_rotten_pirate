set :domain, "hjhart.no-ip.org"
set :application, "the_rotten_pirate"
set :deploy_to, "/Users/james/Sites/#{application}"

set :user, "james"
set :use_sudo, false

set :scm, :git
set :repository,  "git@github.com:hjhart/#{application}.git"
set :branch, 'experimental'
set :git_shallow_clone, 1

role :web, domain
role :app, domain
role :db,  domain, :primary => true

set :deploy_via, :remote_cache
 before "deploy:finalize_update", "deploy:link_shared_files"


namespace :deploy do
  task :start do ; end
  task :stop do ; end
  # Assumes you are using Passenger
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :finalize_update, :except => { :no_release => true } do
    run "chmod -R g+w #{latest_release}" if fetch(:group_writable, true)

    # mkdir -p is making sure that the directories are there for some SCM's that don't save empty folders
    run <<-CMD
      rm -rf #{latest_release}/log &&
      mkdir -p #{latest_release}/public &&
      mkdir -p #{latest_release}/tmp &&
      mkdir -p #{shared_path}/db &&
      ln -s #{shared_path}/log #{latest_release}/log
    CMD

    if fetch(:normalize_asset_timestamps, true)
      stamp = Time.now.utc.strftime("%Y%m%d%H%M.%S")
      asset_paths = %w(images css).map { |p| "#{latest_release}/public/#{p}" }.join(" ")
      run "find #{asset_paths} -exec touch -t #{stamp} {} ';'; true", :env => { "TZ" => "UTC" }
    end
  end
  
  task :link_shared_files, :roles => :app do
    #run "ln -s #{shared_path}/db/downloads.sqlite #{release_path}/db/downloads.sqlite"
    run "ln -s #{shared_path}/config/prowl.yml #{release_path}/config/prowl.yml"
    run "ln -s #{shared_path}/config/config.yml #{release_path}/config/config.yml"
    run "ln -s #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -s #{shared_path}/config/newrelic.yml #{release_path}/config/newrelic.yml"
    run "ln -s #{release_path}/public/assets/ #{shared_path}/assets/"
  end
  
end
