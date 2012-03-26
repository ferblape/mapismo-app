# coding: UTF-8

class DateRangifier

  def initialize(from, to)
    @from = from.utc
    @to = to.utc
  end

  # Returns an array of arrays of ranges
  # in ranges of 24 hours
  def range
    ranges = []
    if (@to-@from) / 3600 > 24
      ranges.push([@from, @from.end_of_day])
      current_date = @from.beginning_of_day
      begin
        current_date = current_date.tomorrow.beginning_of_day
        ranges.push([current_date, current_date.end_of_day])
      end while (current_date.to_date < @to.yesterday.to_date)
      current_date = current_date.tomorrow
      ranges.push([current_date.beginning_of_day, @to])
    else
      h1 = @from.hour + 1
      h2 = @to.hour - 1
      ranges.push([@from, @from + 1.hour - @from.min.minutes - @from.sec])
      h1.upto(h2) do |hour|
        ranges.push([Time.utc(@from.year,@from.month,@from.day,hour,0,0), Time.utc(@from.year,@from.month,@from.day,hour+1,0,0)])
      end
      ranges.push([@to - @to.min.minutes - @to.sec, @to])
    end
    ranges
  end

end