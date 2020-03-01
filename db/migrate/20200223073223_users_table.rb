class UsersTable < ActiveRecord::Migration[6.0]
	def up
		create_table :users do |t|
			t.string :username
			t.string :password
			t.datetime :created_at
			t.datetime :updated_at
		end
	end
	
	def down
		drop_table :users
	end
end
