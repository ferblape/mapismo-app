# coding: UTF-8

class DateRangifier

  def initialize(from, to)
    @from = from.utc
    @to = to.utc
  end

  # Returns an array of arrays of ranges
  # in ranges of 24 hours
  def range
    if (@to - @from) / 3600 > 24
      days_of_diff = (@to - @from) / (3600*24)
      step = if days_of_diff < 7
        24/12
      elsif days_of_diff < 30
        24/6
      else
        24/2
      end
      ranges = []
      ranges += hours_range(@from, @from.end_of_day, step)
      current_date = @from.beginning_of_day
      begin
        current_date = current_date.tomorrow.beginning_of_day
        ranges += hours_range(current_date, current_date.end_of_day, step)
      end while (current_date.to_date < @to.yesterday.to_date)
      current_date = current_date.tomorrow
      ranges += hours_range(current_date.beginning_of_day, @to, step)
      return ranges
    else
      return hours_range(@from, @to, 1)
    end
  end

  private

  def hours_range(from, to, step)
    return [from, to] if(from + step.hours > to)

    ranges = []
    begin
      end_range = from + step.hours
      end_range = to if end_range > to
      ranges.push([from, end_range])
    end while (from += step.hours) < to
    ranges
  end

end