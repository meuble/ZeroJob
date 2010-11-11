module ZeroJobs
  class Job < ActiveRecord::Base
    set_table_name :zero_jobs
    
    class DumpError < StandardError
    end
    
    def self.enqueue(obj, mess)
      job = self.create(:object => obj, :message => mess)
      if job.new_record?
        raise ArgumentError.new("Can't save job : #{job.errors.full_message}")
      else
        JobSender.send_job(job)
      end
      job
    end
    
    def perfom
      self.object.send(self.message)
    end
    
    def terminate!
      self.destroy
    end
    
    def log_error(e)
      self.update_attributes(:failed_at => Time.now, :last_error =>  e.message + "\n" + e.backtrace.join("\n"))
    end
    
    def object
      @object ||= load(self.raw_object)
    end
    
    def object=(value)
      self.raw_object = self.dump(value)
    end
    
    def dump(obj)
      case obj
      when Class              then class_to_string(obj)
      when ActiveRecord::Base then active_record_instance_to_string(obj)
      else obj
      end
    end
    
    def load(str)
      begin
        hash = JSON.parse(str.to_s)
      rescue JSON::ParserError => e
        return nil
      end
      case hash['type']
      when 'class'                  then hash['class_name'].constantize
      when 'active_record_instance' then hash['class_name'].constantize.find(hash['id'].to_i)
      else nil
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