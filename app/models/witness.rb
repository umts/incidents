# frozen_string_literal: true

class Witness < ApplicationRecord
  belongs_to :supervisor_report
  validates :name, presence: true

  def display_info
    [name, address, onboard_bus_display,
     phone_display(:home), phone_display(:cell), phone_display(:work)].reject(&:blank?).join '; '
  end

  def onboard_bus_display
    if onboard_bus?
      'Onboard bus'
    else 'Not onboard bus'
    end
  end

  def phone_display(phone_type)
    raise ArgumentError unless %i[home cell work].include? phone_type

    phone = send "#{phone_type}_phone"
    "#{phone_type.capitalize}: #{phone}" if phone.present?
  end
end
