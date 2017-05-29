require 'prawn-rails'

  # TODO: figure out how to do something like the following
=begin
  pdf.field_row height: 25, units: 8 do |row|
    row.text_field width: 4, field: 'Operator',  value: @incident.driver.name
    row.text_field width: 1,  field: 'Badge No.', value: @incident.driver.badge_number
    row.text_field width: 1,  field: 'Run #',     value: @incident.run
    row.text_field width: 1,  field: 'Block #',   value: @incident.block
    row.text_field width: 1,  field: 'Bus #',     value: @incident.bus
  end
=end

module PrawnFormBoxes
  class RowHelper
    attr_accessor :height, :units, :x, :y, :unit_width
    
    def initialize(height, units, x, y, unit_width)
      @height, @units, @x, @y, @unit_width = 
        height, units, x, y, unit_width
    end
  end

  class PrawnRails::Document
    attr_accessor :row_helper

    def field_row(height:, units:, &block)
      @row_helper = RowHelper.new height, units,
        0, cursor, bounds.width / units
      block.call
      @row_helper = nil
    end

    def text_field(**args)
      start = if args[:start].blank?
                if @row_helper.present?
                  [@row_helper.x, @row_helper.y]
                else raise ArgumentError, 'Must specify starting position'
                end
              else args[:start]
              end
      width = if @row_helper.present?
                @row_helper.unit_width * (args[:width] || 1)
              elsif args[:width].present?
                args[:width]
              else raise ArgumentError, 'Must specify field width'
              end
      height = if args[:height].present?
                 args[:height]
               elsif @row_helper.present?
                 @row_helper.height
               else raise ArgumentError, 'Must specify field height'
               end
      args[:options] ||= {}
      make_text_field start: start, width: width, height: height,
        field: args[:field], value: args[:value], options: args[:options]
      @row_helper.x += width if @row_helper.present?
    end

    def make_text_field(start:, width:, height:, field:, value:, options:)
      bounding_box start, width: width, height: height do
        stroke_bounds
        bounds.add_left_padding 2
        move_down 2
        text field.upcase, size: 6
        text_size = options[:size] || 10
        if value.present?
          unless options[:if] == false || options[:unless] == true
            align = options[:align] || :center
            valign = options[:valign] || :bottom
            value = value.to_s unless value.is_a? Array
            text = if value.is_a? Array
                     value.join "\n"
                   else value.to_s
                   end
            # cursor is current y position
            bounding_box [0, cursor], width: bounds.width do
              text_box text, align: align, size: text_size, valign: valign,
                             overflow: :ellipses
            end
          end
        end
      end
    end
    
    def check_box_field(**args)
      start = if args[:start].blank?
                if @row_helper.present?
                  [@row_helper.x, @row_helper.y]
                else raise ArgumentError, 'Must specify starting position'
                end
              else args[:start]
              end
      width = if args[:width].present?
                if @row_helper.present?
                  args[:width] * @row_helper.unit_width
                else args[:width]
                end
              else raise ArgumentError, 'Must specify field width'
              end
      height = if args[:height].present?
                 args[:height]
               elsif @row_helper.present?
                 @row_helper.height
               else raise ArgumentError, 'Must specify field height'
               end
      args[:per_column] ||= 3
      make_check_box start: start, width: width, height: height,
        field: args[:field], options: args[:options],
        checked: args[:checked], per_column: args[:per_column]
      @row_helper.x += width if @row_helper.present?
    end

    def make_check_box(start:, width:, height:, field:, options:, checked:, per_column:)
      bounding_box start, width: width, height: height do
        stroke_bounds
        bounds.add_left_padding 2
        move_down 2
        text field.upcase, size: 6
        move_down 2
        box_height = cursor
        box_width = (width - 4) / options.each_slice(per_column).count
        options.each_slice(per_column).with_index do |opts, i|
          bounding_box [box_width * i, box_height], width: box_width, height: box_height do
            bounds.add_left_padding 2
            bounds.add_right_padding 2
            move_down 2
            opts.each.with_index do |opt, j|
              overall_index = i * per_column + j
              check_box checked: checked[overall_index], text: opt
              move_down 2
            end # each option
          end # options bounding box
        end # each set of options
      end # field bounding box
    end # method definition

    def check_box(checked:, text:)
      box_y = cursor
      bounding_box [0, box_y], width: 7, height: 7 do
        stroke_bounds
        if checked
          move_down 1
          text 'X', align: :center, size: 6, style: :bold
        end
      end
      bounding_box [9, box_y], width: bounds.width - 9, height: 10 do
        text text, size: 10
      end
    end

  end
end
