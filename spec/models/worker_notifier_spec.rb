# coding: UTF-8

require 'spec_helper'

describe WorkerNotifier do
  describe "#notify!" do
    it "should publish a message in workers channel" do
      $redis.expects(:publish).once.with(Mapismo.workers_channel, instance_of(String))
      subject.notify!("foo")
    end
  end
end