require "rubygems"
require "sinatra"
require 'sinatra/activerecord'
require "active_record"


ActiveRecord::Base.logger = Logger.new('debug.log')
configuration = YAML::load(IO.read('config/database.yml'))
ActiveRecord::Base.establish_connection(configuration['development'])

require_relative "../models/user.rb"
require_relative "../models/review.rb"

class ApplicationController < Sinatra::Base
	configure do
		set :public_folder, "public"
		set :views, "app/views"
        enable :sessions
	end
	
	get "/" do
		redirect "/checkloggedin"
	end 
	
	get "/checkloggedin" do
		"Checked Logged In"
		
		if session["username"] == nil
			redirect "/login"
		else
			redirect "/postreview"
		end
	end 


	post "/login" do
		username =params['username']
		user_pass =params['user_pass']
		
		
		result = User.exists?(username: "#{username}", password: "#{user_pass}")
		
		if(result)
			session["username"] = username;
			
			redirect "/postreview"
        else
			redirect "/login"
		end	
	end
	
	get "/login" do
		erb :signin
	end

    post "/signup" do
		username =params['username']
		password =params['password']
		
		result = User.exists?(username: "#{username}")
		if(result)
			redirect "/login"
		else
			result = User.create({:username => username, :password => password})
            if(result.valid?)
                session["username"] = username
				redirect "/postreview"
			else
				redirect "/signup"
			end
		end
	end

    get "/signup" do
		erb :signup
	end
	
    get "/signout" do
        session.clear
		redirect "/"
	end

    get "/edit" do
            redirect "/"
	end
    
    post "/postreview" do
        if session["username"] != nil
			title =params['title']
			rating =params['rating']
			review =params['review']
			result = Review.create({:title => title, :rating => rating, :body => review, :user_id => User.find_by(:username => session["username"]).id})
			if(result.valid?)
				review_id = result.id
				redirect "/viewreview/#{review_id}"
			else
			  redirect "/postreview"
			end
        else 
            #not logged in. Goodbye
            redirect "/"
		end
    end

	get "/postreview" do
        if session["username"] != nil
			erb :postreview
		else
			redirect "/"
		end
	end
	
	post "/editreview" do
        if session["username"] != nil
			review_id = params["current_review_id"]
			review = Review.find_by(id: "#{review_id}")
			@review_data = review
			posters_user_id = review.user_id
			user_result = User.find_by(id: "#{posters_user_id}")
			poster_username = user_result.username
			
			if(poster_username == session["username"])
				erb :edit
			else
				redirect "/"
			end
        else 
            redirect "/"
		end
	end
	
    post "/edit" do
        if session["username"] != nil
			review_id = params["current_review_id"]
			review = Review.find_by(id: "#{review_id}")
			@review_data = review
			posters_user_id = review.user_id
			user_result = User.find_by(id: "#{posters_user_id}")
			poster_username = user_result.username

			if(poster_username == session["username"])
				#good, they can edit
				title =params['title']
				rating =params['rating']
				review =params['body']
				puts "Title: #{title}"
				puts "Rating: #{rating}"
				puts "Review: #{review}"
				result = Review.update(review_id, "title" => "#{title}", "rating" => "#{rating}", "body" => "#{review}")
				if(result)
					redirect "/viewreview/#{review_id}"
				else 
					redirect "/edit"
				end
			else
				#no, they can't edit
				redirect "/"
			end
        else 
            #not logged in. Goodbye
            redirect "/"
		end
    end
    
    

    post "/signout" do
        session.clear
		redirect "/"
    end
    
    get "/signout" do
        session.clear
		redirect "/"
    end
    
	get "/delete" do
		redirect "/"
	end
	
    get "/viewreview/:review_id" do
        if session["username"] != nil
			passed_review_id = params["review_id"]
			@review_data = Review.find_by(id: "#{passed_review_id}")
			if(@review_data.valid?)
				erb :viewreview
			else 
				redirect "/postreview"
			end
		else
			redirect "/"
		end
    end 


	post "/delete" do
		if session["username"] != nil
			review_id = params["current_review_id"]
			review = Review.find_by(id: "#{review_id}")
			posters_user_id = review.user_id

			user_result = User.find_by(id: "#{posters_user_id}")

			poster_username = user_result.username

			if(poster_username == session["username"])
				#good, they can edit
				
				current_review_id =params['current_review_id']
				result = Review.find_by(id: "#{current_review_id}")
				result = Review.destroy(current_review_id)
				if(result.valid?)
					current_review_id = result.id
					redirect "/"
					puts "Review #{Review.last.id} Deleted!"
				else 
					redirect "/viewreview#{current_review_id}"
				end
			else
				#no, they can't edit
				redirect "/"
			end	
		else
			#not logged in. Goodbye
			redirect "/"
		end
	end
end