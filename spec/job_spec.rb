require "spec_helper"
require File.dirname(__FILE__) + '/database'

describe ZeroJobs::Job do
  before(:each) do
    @job = ZeroJobs::Job.new
  end
  
  it "should transform class to string" do
    result = @job.class_to_string(SampleObject)
    result.class.should == String
    lambda do
      json_result = JSON.parse(result)
      json_result.should == {"class_name" => "SampleObject", "type" => "class"}
    end.should_not raise_error
  end
  
  it "should transform ActiveRecord instace to JSON string" do
    sample_object = SampleObject.create(:count => 42)
    result = @job.active_record_instance_to_string(sample_object)
    result.class.should == String
    
    lambda do
      json_result = JSON.parse(result)
      json_result.should == {"class_name" => "SampleObject", "id" => sample_object.id, "type" => "active_record_instance"}
    end.should_not raise_error
  end
  
  it "should raise when trying to dump new_record" do
    sample_object = SampleObject.new(:count => 42)
    lambda do
      @job.active_record_instance_to_string(sample_object)
    end.should raise_error(ZeroJobs::Job::DumpError)
  end
  
  it "should dump object in string for an instance" do
    sample_object = SampleObject.create(:count => 2)
    @job.should_receive(:active_record_instance_to_string)
    @job.dump(sample_object)
  end

  it "should dump object in string for a class" do
    sample_object = SampleObject
    @job.should_receive(:class_to_string)
    @job.dump(sample_object)
  end
  
  it "should load object from stringified class" do
    obj = @job.load('{"class_name":"SampleObject","type":"class"}')
    obj.class.should == Class
    obj.name.should == "SampleObject"
  end
  
  it "should load object from stringified instance" do
    sample_object = SampleObject.create(:count => 2)
    
    obj = @job.load('{"class_name":"SampleObject","type":"active_record_instance","id":' + sample_object.id.to_s + '}')
    obj.class.should == SampleObject
    obj.should == sample_object
  end
  
  it "should have a nil object" do
    @job.object.should be_nil
  end
  
  it "should have an object" do
    sample_object = SampleObject.create(:count => 42)
    @job.should_receive(:load).once().and_return(sample_object)
    @job.object.should == sample_object
    @job.object.should == sample_object
  end
  
  it "should kepp an object" do
    dumped_obj = stub
    loaded_obj = stub
    @job.should_receive(:dump).and_return(dumped_obj)
    @job.object = Object.new
    @job.raw_object.should == dumped_obj
    
    @job.should_receive(:load).with(dumped_obj).and_return(loaded_obj)
    @job.object.should == loaded_obj
  end
  
  it "should enqueue job to save it and send it" do
    sample_object = SampleObject.create(:count => 42)
    ZeroJobs::Job.should_receive(:send_job)
    lambda do
      job = ZeroJobs::Job.enqueue sample_object, :some_method
      job.object.should == sample_object
      job.message.should == :some_method
    end.should change(ZeroJobs::Job, :count)
  end
end