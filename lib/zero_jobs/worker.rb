module ZeroJobs
  class Worker
    def initialize
      ZeroJobs::JobSender.initialize_zmq_context
      ZeroJobs::JobSender.initialize_zmq_pull_socket
    end
    
    def wait_job
      data = ZeroJobs::JobSender.pull_socket.recv
      
      options = JSON.parse(data)
      options['class'].constantize.find(options['id'])
    end
    
    def run
      while true
        job = self.wait_job
        begin
          job.perform
          job.terminate!
        rescue Exception => e
          job.log_error(e)
        end
      end
    end
  end
end
