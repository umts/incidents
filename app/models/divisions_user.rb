# frozen_string_literal: true

class DivisionsUser < ApplicationRecord
  belongs_to :user
  belongs_to :division
end
