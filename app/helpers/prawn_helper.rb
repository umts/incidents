# frozen_string_literal: true

module PrawnHelper

end

class Prawn::RailsDocument
  def form_box(start, width:, height:, name:, value:)
    bounding_box start, width: width, height: height do
      stroke_bounds
      bounds.add_left_padding 2
      move_down 2
      text name.upcase, size: 6
      if value.present?
        move_down 2
        text value
      end
    end
  end
end
