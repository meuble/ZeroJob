require 'rubygems'
require 'active_record'

require 'zero_jobs'

module Rails
  def self.env; "spec"; end
  def self.root; File.dirname(__FILE__); end
end