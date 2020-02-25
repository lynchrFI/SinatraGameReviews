ENV['SINATRA_ENV'] ||= "development"
require "rubygems"
require "sinatra"
require "active_record"

ActiveRecord::Base.establish_connection(
	:adapter => 'sqlite3',
	:database => "db/#{ENV['SINATRA_ENV']}.sqlite"
)

#Link To Models Here
