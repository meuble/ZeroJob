require "spec_helper"

describe ZeroJobs::Worker do
  it "should initialize zmq at creation" do
    ZeroJobs::JobSender.should_receive(:initialize_zmq_context)
    ZeroJobs::JobSender.should_receive(:initialize_zmq_pull_socket)
    ZeroJobs::Worker.new
  end
  
  it "should wait for a job" do
    ZeroJobs::JobSender.should_receive(:initialize_zmq_context)
    ZeroJobs::JobSender.should_receive(:initialize_zmq_pull_socket)
    job = ZeroJobs::Job.create(:object => SampleObject.create(:count => 42), :message => :some_method)
    worker = ZeroJobs::Worker.new
    ZeroJobs::JobSender.should_receive(:pull_socket).and_return(mock(:recv => {"class" => job.class.name, "id" => job.id}.to_json))
    worker.wait_job.should == job
  end
end