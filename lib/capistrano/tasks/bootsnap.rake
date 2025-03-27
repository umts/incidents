# frozen_string_literal: true

namespace :bootsnap do
  desc 'Precompile bootsnap'
  task :precompile do
    on roles %i[web app] do
      within release_path do
        execute :bootsnap, '--cache-dir', release_path, :precompile, '--gemfile', 'app/', 'config/', 'lib/'
      end
    end
  end
end
