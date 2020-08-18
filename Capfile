%w[ setup deploy pending bundler rails passenger scm/git].each do |lib|
  require "capistrano/#{lib}"
end

install_plugin Capistrano::SCM::Git
