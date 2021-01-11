namespace :sidekiq do
  task :restart do
    on roles(:app) do
      execute :sudo, :systemctl, :stop, 'sidekiq.service'
      execute :sudo, :systemctl, :start, 'sidekiq.service'
    end
  end
end
