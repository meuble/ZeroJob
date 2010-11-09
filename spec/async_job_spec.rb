require "spec_helper"

SampleObject.send(:include, ZeroJobs::AsyncJob)
SampleObject.send(:extend, ZeroJobs::AsyncJob)

describe ZeroJobs::AsyncJob do
  it "should execute an instance method asyncronously via enqueuing a job" do
    obj = SampleObject.create(:count => 42)
    ZeroJobs::JobSender.should_receive(:send_job)
    lambda do
      obj.send_async(:some_method).class.should == ZeroJobs::Job
    end.should change(ZeroJobs::Job, :count)
  end
  
  it "should execute a class method asyncronously via enqueuing a job" do
    obj = SampleObject
    ZeroJobs::JobSender.should_receive(:send_job)
    lambda do
      obj.send_async(:some_method).class.should == ZeroJobs::Job
    end.should change(ZeroJobs::Job, :count)
  end
end