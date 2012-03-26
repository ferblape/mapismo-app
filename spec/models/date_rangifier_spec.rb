# coding: UTF-8

require 'spec_helper'

describe DateRangifier do
  it "should return a range of dates in steps of days if the period is longer than 24 hours" do
    from = Time.utc(2010,10,13,10,00,00)
    to   = Time.utc(2010,10,15,15,30,00)
    result = DateRangifier.new(from, to).range
    result.should include([from, from.end_of_day])
    result.should include([Time.utc(2010,10,14,00,00,00).beginning_of_day, Time.utc(2010,10,14,23,59,59).end_of_day])
    result.should include([to.beginning_of_day, to])
  end

  it "should return a range of dates in steps of hours if the period is shorter than 24 hours" do
    from = Time.utc(2010,10,15,10,10,00)
    to   = Time.utc(2010,10,15,15,30,00)
    result = DateRangifier.new(from, to).range
    result.should include([from, Time.utc(2010,10,15,11,00,00)])
    11.upto(14) do |hour|
      result.should include([Time.utc(2010,10,15,hour,00,00), Time.utc(2010,10,15,hour+1,00,00)])
    end
    result.should include([Time.utc(2010,10,15,15,00,00), to])
  end
end