# frozen_string_literal: true

# Pilfered from the incidents model
SECOND_REASON_CODES = [
  'a-1: Line Service - Stopped',
  'a-2: Line Service - In Traffic, Moving',
  'a-3: Stop - Exit',
  'a-4: Stop - Enter',
  'a-5: At Stop',
  'a-6: Right Turn',
  'a-7: Left Turn',
  'a-8: Miscellaneous',
  'b-1: Line Service - Stopped',
  'b-2: Line Service - In Traffic, Moving',
  'b-3: Stop - Exit',
  'b-4: Stop - Enter',
  'b-5: At Stop',
  'b-6: Right Turn',
  'b-7: Left Turn',
  'b-8: Miscellaneous'
]

namespace :supplementary_reason_codes do
  # Example invocation: rails supplementary_reason_codes:create
  task create: :environment do
    SECOND_REASON_CODES.each do |code|
      identifier, description = code.split ': '
      new_code = SupplementaryReasonCode.create! identifier: identifier,
                                                 description: description
      unless new_code.full_label == code
        fail 'You dun goofed'
      end
    end
  end

  task migrate: :environment do
  # Example invocation: rails supplementary_reason_codes:migrate
    incidents = Incident.where.not second_reason_code: nil
    incidents.each do |incident|
      identifier = incident.second_reason_code.split(': ').first
      code = SupplementaryReasonCode.find_by! identifier: identifier
      incident.update supplementary_reason_code: code
    end
  end
end
