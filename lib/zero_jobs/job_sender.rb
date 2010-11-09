module ZeroJobs
  module JobSender
    class NotConfigured < Exception; end
    class UninitializedZMQ < Exception; end
      
    class << self
      attr_accessor :socket_push_endpoint, :worker_instance, :context, :socket
    end
    
    def self.socket_push_endpoint
      @socket_push_endpoint || raise_unconfigured_exception    
    end

    def self.worker_instance
      @worker_instance || raise_unconfigured_exception
    end
    
    def self.context
      @context || raise_uninitialized_zmq
    end
    
    def self.socket
      @socket || raise_uninitialized_zmq
    end
    
    def self.raise_unconfigured_exception
      raise NotConfigured.new("No configuration provided.")
    end
    
    def self.raise_uninitialized_zmq
      raise UninitializedZMQ.new("ZMQ is not ready.")
    end
    
    def self.configuration=(hash)
      self.socket_push_endpoint = hash[:socket_push_endpoint]
      self.worker_instance = hash[:worker_instance]
    end
    
    def self.load_from_yaml_config_file
      config = YAML.load(ERB.new(File.read(File.join(::Rails.root,"config","zero_jobs.yml"))).result)[::Rails.env]
      raise NotConfigured.new("Unable to load configuration for #{::Rails.env} from zero_jobs.yml. Is it set up?") if config.nil?
      self.configuration = config.with_indifferent_access
    end
    
    def self.initialize_zmq_context
      self.context = ZMQ::Context.new(1)
    end
    
    def self.initialize_zmq_push_socket
      self.socket = self.context.socket(ZMQ::PUSH)
      self.socket.bind(self.socket_push_endpoint)
    end

    def self.initialize_zmq_pull_socket
      self.socket = self.context.socket(ZMQ::PULL)
      self.socket.bind(self.socket_pull_endpoint)
    end
    
    def self.job_to_json(job)
      {:class => job.class.name,
        :id => job.id,
        :message => job.message}.to_json
    end
    
    def self.send_job(job)
      self.socket.send(self.job_to_json(job))
    end
  end
end
