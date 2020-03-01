class ReviewsTable < ActiveRecord::Migration[6.0]
	def up
		create_table :reviews do |t|
			t.string :title
            t.integer :rating
			t.string :body
			t.datetime :created_at
			t.datetime :updated_at
			t.string :user_id
		end
	end
	
	def down
		drop_table :reviews
	end
end