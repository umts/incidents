class Incident < ApplicationRecord
  def occurred_at_readable
    occurred_at.strftime '%A, %B %e, %l:%M %P'
  end
end
