# frozen_string_literal: true

namespace :db do
  task amplifying_comments: :environment do
    SupervisorReport.find_each do |s|
      case s.test_status
      when 'Post Accident: No threshold met (no drug test)'
        new_comment = s.reason_threshold_not_met
      when 'Post Accident: Threshold met and discounted (no drug test)'
        new_comment = s.reason_driver_discounted
      else
        next
      end

      if new_comment && s.amplifying_comments.present? && new_comment != s.amplifying_comments
        new_comment += "\n\n#{s.amplifying_comments}"
        s.update(amplifying_comments: new_comment)
      end
    end
  end
end
