# frozen_string_literal: true

namespace :passwords do
  task initialize: :environment do
    User.all.each do |u|
      u.set_default_password and u.save!
    end
  end
end
