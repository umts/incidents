# frozen_string_literal: true

namespace :divisions do
  desc 'Migrate users from string divisions to the table association.'
  task :migrate do
    User.all.each do |u|
      division_name = u.attributes[:division]
      division = Division.where(name: division_name).first_or_create
      u.update! division_id: division.id
    end
  end
end
