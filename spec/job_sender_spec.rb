require "spec_helper"

describe ZeroJobs::JobSender do
  it "allows setting of the worker_instance" do
    ZeroJobs::JobSender.worker_instance = "123456"
    ZeroJobs::JobSender.worker_instance.should == "123456"
  end
  
  it "allows setting of the socket_push_endpoint" do
    ZeroJobs::JobSender.socket_push_endpoint = "some_endpoint"
    ZeroJobs::JobSender.socket_push_endpoint.should == "some_endpoint"
  end
  
  it "allows setting of the socket_pull_endpoint" do
    ZeroJobs::JobSender.socket_pull_endpoint = "some_endpoint"
    ZeroJobs::JobSender.socket_pull_endpoint.should == "some_endpoint"
  end
  
  it "allows setting of the context" do
    ZeroJobs::JobSender.context = "some_context"
    ZeroJobs::JobSender.context.should == "some_context"
  end
  
  it "allows setting of the push_socket" do
    ZeroJobs::JobSender.push_socket = "some_socket"
    ZeroJobs::JobSender.push_socket.should == "some_socket"
  end
  
  it "allows setting of the pull_socket" do
    ZeroJobs::JobSender.pull_socket = "some_socket"
    ZeroJobs::JobSender.pull_socket.should == "some_socket"
  end

  it "should raise if asking for push socket without configuration" do
    ZeroJobs::JobSender.push_socket = nil
    lambda do
      ZeroJobs::JobSender.push_socket
    end.should raise_error(ZeroJobs::JobSender::UninitializedZMQ)
  end
  
  it "should raise if asking for pull socket without configuration" do
    ZeroJobs::JobSender.pull_socket = nil
    lambda do
      ZeroJobs::JobSender.pull_socket
    end.should raise_error(ZeroJobs::JobSender::UninitializedZMQ)
  end
  
  it "should raise if asking for context without configuration" do
    ZeroJobs::JobSender.context = nil
    lambda do
      ZeroJobs::JobSender.context
    end.should raise_error(ZeroJobs::JobSender::UninitializedZMQ)
  end
  
  it "should raise if asking for socket_push_endpoint without configuration" do
    ZeroJobs::JobSender.socket_push_endpoint = nil
    lambda do
      ZeroJobs::JobSender.socket_push_endpoint
    end.should raise_error(ZeroJobs::JobSender::NotConfigured)
  end
  
  it "should raise if asking for socket_pull_endpoint without configuration" do
    ZeroJobs::JobSender.socket_pull_endpoint = nil
    lambda do
      ZeroJobs::JobSender.socket_pull_endpoint
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
    ZeroJobs::JobSender.socket_push_endpoint.should == "fromyaml"
    ZeroJobs::JobSender.socket_pull_endpoint.should == "fromyamlpull"
  end
  
  it "should allow setting the configuration in bulk" do
    ZeroJobs::JobSender.configuration = {:worker_instance => 1234, :socket_push_endpoint => "someendpoint2", :socket_pull_endpoint => "someendpoint3"}
    ZeroJobs::JobSender.worker_instance.should == 1234
    ZeroJobs::JobSender.socket_push_endpoint.should == "someendpoint2"
    ZeroJobs::JobSender.socket_pull_endpoint.should == "someendpoint3"
  end

  it "should initialize ZMQ context" do
    mock_context = mock()
    ZMQ::Context.should_receive(:new).and_return(mock_context)
    
    ZeroJobs::JobSender.initialize_zmq_context
    ZeroJobs::JobSender.context.should == mock_context
  end
  
  it "should initialize ZMQ PUSH connction" do
    mock_context = mock(:socket => mock(:bind))
    ZeroJobs::JobSender.should_receive(:context).and_return(mock_context)
    
    ZeroJobs::JobSender.initialize_zmq_push_socket
    ZeroJobs::JobSender.push_socket.should == mock_context.socket
  end

  it "should send job throught a PUSH socket" do
    job = ZeroJobs::Job.create(:object => SampleObject.create(:count => 42), :message => :some_method)
    mock_context = mock(:socket => mock(:bind))
    mock_context.socket.should_receive(:send)
    ZeroJobs::JobSender.should_receive(:context).and_return(mock_context)

    ZeroJobs::JobSender.initialize_zmq_push_socket
    ZeroJobs::JobSender.send_job(job)
  end
  
  it "should initialize ZMQ PULL connction" do
    mock_context = mock(:socket => mock())
    mock_context.socket.should_receive(:connect)
    ZeroJobs::JobSender.should_receive(:context).and_return(mock_context)
    
    ZeroJobs::JobSender.initialize_zmq_pull_socket
    ZeroJobs::JobSender.pull_socket.should == mock_context.socket
  end
  
  it "should tranform job to json" do
    job = ZeroJobs::Job.create(:object => SampleObject.create(:count => 42), :message => :some_method)
    result = ZeroJobs::JobSender.job_to_json(job)
    result.class.should == String
    
    lambda do
      json_result = JSON.parse(result)
      json_result.should == {"class" => job.class.name, "id" => job.id}
    end.should_not raise_error    
  end
end