require File.dirname(__FILE__) + '/database'
require "spec_helper"

class SampleObject < ActiveRecord::Base
end

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
      json_result.should == {"class_name" => "SampleObject", "id" => 1, "type" => "active_record_instance"}
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
  
  it "should have an object" do
    @job.object.should be_nil
  end
end