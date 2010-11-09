module ZeroJobs
  class Job < ActiveRecord::Base
    set_table_name :zero_jobs
    
    class DumpError < StandardError
    end
    
    def object
      @object
    end
    
    def dump(obj)
      case obj
      when Class              then class_to_string(obj)
      when ActiveRecord::Base then active_record_instance_to_string(obj)
      else obj
      end
    end
    
    def load(str)
      hash = JSON.parse(str)
      case hash['type']
      when 'class'                  then hash['class_name'].constantize
      when 'active_record_instance' then hash['class_name'].constantize.find(hash['id'].to_i)
      else arg
      end
    end

    def active_record_instance_to_string(obj)
      raise DumpError.new("Can't dump unsaved instance. Need an id to retreive it later") if obj.new_record?
      {:type => :active_record_instance, :class_name => obj.class.name, :id => obj.id}.to_json
    end
    
    def class_to_string(obj)
      {:type => :class, :class_name => obj.name}.to_json
    end
  end
end
