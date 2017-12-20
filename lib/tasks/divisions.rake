# frozen_string_literal: true

namespace :divisions do
  desc 'Migrate from string division to join table divisions'
  task migrate: :environment do
    User.all.each do |u|
      division = Division.where(name: u.attributes['division']).first_or_create
      u.divisions << division
      u.save!
    end
  end
end
