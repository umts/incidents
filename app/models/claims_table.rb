class ClaimsTable < ActiveRecord::Base
  self.abstract_class = true
  establish_connection "claims_#{Rails.env}".to_sym
end
