module ZeroJobs
  module JobSender
    class NotConfigured < Exception; end
      
    class << self
      attr_accessor :socket_endpoint, :worker_instance, :context, :socket
    end
    
    def self.socket_endpoint
      @socket_endpoint || raise_unconfigured_exception    
    end

    def self.worker_instance
      @worker_instance || raise_unconfigured_exception
    end
    
    def self.raise_unconfigured_exception
      raise NotConfigured.new("No configuration provided.")
    end
    
    def self.configuration=(hash)
      self.socket_endpoint = hash[:socket_endpoint]
      self.worker_instance = hash[:worker_instance]
    end
    
    def self.load_from_yaml_config_file
      config = YAML.load(ERB.new(File.read(File.join(::Rails.root,"config","zero_jobs.yml"))).result)[::Rails.env]
      raise NotConfigured.new("Unable to load configuration for #{::Rails.env} from zero_jobs.yml. Is it set up?") if config.nil?
      self.configuration = config.with_indifferent_access
    end
    
    def self.initialize_zmq_socket
      self.load_from_yaml_config_file
      @context = ZMQ::Context.new(1)
      @socket = @context.socket(ZMQ::PUSH)
      @socket.bind(@socket_endpoint)
    end

  end
end
