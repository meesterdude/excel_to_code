# frozen_string_literal: true

module ExcelFunctions
  def ceiling(number, multiple, mode = 0)
    return number if number.is_a?(Symbol)
    return multiple if multiple.is_a?(Symbol)
    return mode if mode.is_a?(Symbol)

    number = number_argument(number)
    multiple = number_argument(multiple)
    mode = number_argument(mode)
    return :value unless number.is_a?(Numeric)
    return :value unless multiple.is_a?(Numeric)
    return :value unless mode.is_a?(Numeric)
    return 0 if multiple.zero?

    if mode.zero? || number.positive?
      whole, remainder = number.divmod(multiple)
      # rj considering any super small values worth ignoring
      num_steps = remainder > 0.00001 ? whole + 1 : whole
      num_steps * multiple
    else # Need to round negative away from zero
      -ceiling(-number, multiple, 0)
    end
  end
end
