require "spec_helper"

describe ZeroJobs::JobSender do
  it "allows setting of the worker_instance" do
    ZeroJobs::JobSender.worker_instance = "123456"
    ZeroJobs::JobSender.worker_instance.should == "123456"
  end
  
  it "allows setting of the socket_endpoint" do
    ZeroJobs::JobSender.socket_endpoint = "some_endpoint"
    ZeroJobs::JobSender.socket_endpoint.should == "some_endpoint"
  end
  
  it "should raise if asking for socket_endpoint without configuration" do
    ZeroJobs::JobSender.socket_endpoint = nil
    lambda do
      ZeroJobs::JobSender.socket_endpoint
    end.should raise_error(ZeroJobs::JobSender::NotConfigured)
  end
  
  it "should raise if asking for worker_instance without configuration" do
    ZeroJobs::JobSender.worker_instance = nil
    lambda do
      ZeroJobs::JobSender.worker_instance
    end.should raise_error(ZeroJobs::JobSender::NotConfigured)
  end
  
  it "can load the configuration via zero_jobs.yml" do
    ZeroJobs::JobSender.load_from_yaml_config_file
    ZeroJobs::JobSender.worker_instance.should == "1234fromyaml"
    ZeroJobs::JobSender.socket_endpoint.should == "fromyaml"
  end
  
  it "should allow setting the configuration in bulk" do
    ZeroJobs::JobSender.configuration = {:worker_instance => 1234, :socket_endpoint => "someendpoint2"}
    ZeroJobs::JobSender.worker_instance.should == 1234
    ZeroJobs::JobSender.socket_endpoint.should == "someendpoint2"
  end
  
  it "should initialize ZMQ connction" do
    mock_context = mock(:socket => mock(:blind))
    ZMQ::Context.should_receive(:new).and_return(mock_context)
    
    ZeroJobs::JobSender.initialize_zmq_socket
    ZeroJobs::JobSender.context.should == mock_context
    ZeroJobs::JobSender.socket.should == mock_context.socket
  end

  it "should send job throught socket" do
    job = ZeroJobs::Job.create(:object => SampleObject.create(:count => 42), :message => :some_method)
    mock_context = mock(:socket => mock(:blind))
    mock_context.socket.should_receive(:send)
    ZMQ::Context.should_receive(:new).and_return(mock_context)
    ZeroJobs::JobSender.initialize_zmq_socket
    ZeroJobs::JobSender.send_job(job)
  end
  
  it "should tranform job to json" do
    job = ZeroJobs::Job.create(:object => SampleObject.create(:count => 42), :message => :some_method)
    result = ZeroJobs::JobSender.job_to_json(job)
    result.class.should == String
    
    lambda do
      json_result = JSON.parse(result)
      json_result.should == {"class" => job.class.name, "id" => job.id, "message" => job.message.to_s}
    end.should_not raise_error    
  end
end