# ZeroJobs
autoload :ActiveRecord, 'activerecord'

require 'rubygems'
require 'zmq'

require 'zero_jobs'
require File.dirname(__FILE__) + '/zero_jobs/job'
require File.dirname(__FILE__) + '/zero_jobs/job_sender'
