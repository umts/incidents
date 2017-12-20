# frozen_string_literal: true

namespace :passwords do
  task initialize: :environment do
    User.all.each do |u|
      u.password = u.last_name
      u.password_confirmation = u.last_name
      u.save!
    end
  end
end
