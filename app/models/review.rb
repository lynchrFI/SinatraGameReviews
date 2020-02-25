class Review < ActiveRecord::Base
	belongs_to :user
	validates :title, presence: true
	validates :rating, presence: true
	validates :body, presence: true
end