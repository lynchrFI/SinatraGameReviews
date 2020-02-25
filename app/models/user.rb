class User < ActiveRecord::Base
	has_many :reviews
	validates :username, presence: true
	validates :password, presence: true
end