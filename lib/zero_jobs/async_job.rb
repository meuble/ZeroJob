module ZeroJobs
  module AsyncJob
    def send_async(method)
      ZeroJobs::Job.enqueue self, method.to_sym
    end
  end                               
end