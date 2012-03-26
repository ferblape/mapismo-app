# coding: UTF-8

require 'spec_helper'

describe DateRangifier do
  context "when the period is shorter than 7 days" do
    it "should return a range of dates in steps of 2 hours" do
      from = Time.utc(2010,10,13,10,20,00)
      to   = Time.utc(2010,10,15,15,30,00)
      result = DateRangifier.new(from, to).range
      result.should include([Time.utc(2010,10,13,10,20,00),Time.utc(2010,10,13,12,20,00)])
      result.should include([Time.utc(2010,10,13,12,20,00),Time.utc(2010,10,13,14,20,00)])
      result.should include([Time.utc(2010,10,13,14,20,00),Time.utc(2010,10,13,16,20,00)])
      result.should include([Time.utc(2010,10,13,16,20,00),Time.utc(2010,10,13,18,20,00)])
      result.should include([Time.utc(2010,10,13,18,20,00),Time.utc(2010,10,13,20,20,00)])
      result.should include([Time.utc(2010,10,13,20,20,00),Time.utc(2010,10,13,22,20,00)])
      result.should include([Time.utc(2010,10,14,00,00,00),Time.utc(2010,10,14,02,00,00)])
      result.should include([Time.utc(2010,10,14,02,00,00),Time.utc(2010,10,14,04,00,00)])
      result.should include([Time.utc(2010,10,14,04,00,00),Time.utc(2010,10,14,06,00,00)])
      result.should include([Time.utc(2010,10,14,06,00,00),Time.utc(2010,10,14,8,00,00)])
      result.should include([Time.utc(2010,10,14,8,00,00),Time.utc(2010,10,14,10,00,00)])
      result.should include([Time.utc(2010,10,14,10,00,00),Time.utc(2010,10,14,12,00,00)])
      result.should include([Time.utc(2010,10,14,12,00,00),Time.utc(2010,10,14,14,00,00)])
      result.should include([Time.utc(2010,10,14,14,00,00),Time.utc(2010,10,14,16,00,00)])
      result.should include([Time.utc(2010,10,14,16,00,00),Time.utc(2010,10,14,18,00,00)])
      result.should include([Time.utc(2010,10,14,18,00,00),Time.utc(2010,10,14,20,00,00)])
      result.should include([Time.utc(2010,10,14,20,00,00),Time.utc(2010,10,14,22,00,00)])
      result.should include([Time.utc(2010,10,15,00,00,00),Time.utc(2010,10,15,02,00,00)])
      result.should include([Time.utc(2010,10,15,02,00,00),Time.utc(2010,10,15,04,00,00)])
      result.should include([Time.utc(2010,10,15,04,00,00),Time.utc(2010,10,15,06,00,00)])
      result.should include([Time.utc(2010,10,15,06,00,00),Time.utc(2010,10,15,8,00,00)])
      result.should include([Time.utc(2010,10,15,8,00,00),Time.utc(2010,10,15,10,00,00)])
      result.should include([Time.utc(2010,10,15,10,00,00),Time.utc(2010,10,15,12,00,00)])
      result.should include([Time.utc(2010,10,15,12,00,00),Time.utc(2010,10,15,14,00,00)])
      result.should include([Time.utc(2010,10,15,14,00,00),Time.utc(2010,10,15,15,30,00)])
    end
  end

  context "when the period is shorter than 24 hours" do
    it "should return a range of dates in steps of 1 hour" do
      from = Time.utc(2010,10,15,10,10,00)
      to   = Time.utc(2010,10,15,15,30,00)
      result = DateRangifier.new(from, to).range
      result.should include([from, Time.utc(2010,10,15,11,10,00)])
      11.upto(14) do |hour|
        result.should include([Time.utc(2010,10,15,hour,10,00), Time.utc(2010,10,15,hour+1,10,00)])
      end
      result.should include([Time.utc(2010,10,15,15,10,00), to])
    end
  end
end