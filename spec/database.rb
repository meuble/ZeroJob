require 'logger'
gem 'sqlite3-ruby'


# ActiveRecord::Base.logger = Logger.new('/tmp/zero_jobs_test.log')
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => '/tmp/zero_jobs_test.sqlite')
ActiveRecord::Migration.verbose = false
ActiveRecord::Base.default_timezone = :utc if Time.zone.nil?

ActiveRecord::Schema.define do

  create_table :zero_jobs, :force => true do |table|
    table.text :raw_object
    table.string :message
    table.datetime :failed_at, :default => 0
    table.text :last_error
    table.timestamps
  end
  
  create_table :sample_objects, :force => true do |table|
    table.integer :count
    table.timestamps
  end
end
