# frozen_string_literal: true

class InjuredPassenger < ApplicationRecord
  belongs_to :incident_report
  validates :name, :nature_of_injury, presence: true

  def display_info
    [name, address, nature_of_injury, transported_to_hospital_display,
     phone_display(:home), phone_display(:cell), phone_display(:work)].reject(&:blank?).join '; '
  end

  def transported_to_hospital_display
    if transported_to_hospital?
      'Transported to hospital by ambulance'
    else 'Not transported to hospital by ambulance'
    end
  end

  def phone_display(phone_type)
    raise ArgumentError unless %i[home cell work].include? phone_type

    phone = send "#{phone_type}_phone"
    "#{phone_type.capitalize}: #{phone}" if phone.present?
  end
end
