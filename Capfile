%w[setup deploy pending bundler rails passenger scm/git sidekiq].each do |lib|
  require "capistrano/#{lib}"
end

install_plugin Capistrano::SCM::Git
install_plugin Capistrano::Sidekiq
install_plugin Capistrano::Sidekiq::Systemd

Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
