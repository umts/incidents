# frozen_string_literal: true

namespace :divisions do
  desc 'Add claims IDs to divisions'
  task add_claims_numbers: :environment do
    Division.find_by(name: 'NOHO').update! claims_id: 3
    Division.find_by(name: 'SMECH').update! claims_id: 2
    Division.find_by(name: 'SPFLD').update! claims_id: 2
  end
end
