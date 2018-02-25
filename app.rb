require 'sinatra'
require 'open-uri'
require 'nokogiri'
require 'json'
require 'sinatra/activerecord'
require "./models/models.rb"
require "./models/users.rb"

enable :sessions

get '/' do
	@user = User.find(session[:id]) if session[:id]
	@parse = Parser.new
	get_parser
	erb :index
end

#Просмотр постов пользователя
get "/posts/show" do
	if session[:id]
		@user = User.find(session[:id])
		a = Post.all
		@posts = a.find_all{|e| e[:owner_id] == @user[:id]}
		erb :'posts/show'
	else 
		erb :'users/login'
	end
end

get '/post/:id' do
	@user = User.find(session[:id]) if session[:id]
	@post = Post.find(params[:id])
	erb :post_page
end

get '/create' do
	if session[:id]
		@user = User.find(session[:id]) if session[:id]
		erb :create
	else 
		erb :'users/login'
	end
end

post '/registrations' do
	a = User.find_by(name: params[:name])
	unless a
		@user = User.create(name: params[:name], email: params[:email], password: params[:password])
		session[:id] = @user.id
		redirect '/users/home'
	else
		erb :'eror/dont_name'
	end
end

get '/users/home' do
	puts session[:id]
	@user = User.find(session[:id]) if session[:id]
	erb :'users/home'
end

get '/registrations/signup' do
	@user = User.find(session[:id]) if session[:id]
	erb :registrations
end

get '/sessions/login' do
	@user = User.find(session[:id]) if session[:id]
	puts session
	erb :'users/login'
end

post '/sessions' do
	@user = User.find_by(email: params[:email], password: params[:password])
	if @user != nil
		session[:id] = @user.id
		redirect 'users/home'
	else
		erb :'eror/session_eror'
	end
end

get '/sessions/logout' do
	session.clear
	redirect '/'
end

# create post
post '/post' do
	if session[:id]
		@user = User.find(session[:id])
		@post = Post.create(title: params[:title], body: params[:body], owner_id: @user[:id])
		redirect '/posts/show'
	else
		erb :'/sessions/login'
	end
end

# update post
put '/post/:id' do
	if session[:id]
		@post = Post.find(params[:id])
		if @post[:owner_id] == session[:id]
			@post.update(title: params[:title], body: params[:body])
			@post.save
			redirect '/post/'+params[:id]
		else
			erb :'eror/no_access'
		end
	else
		erb :'/sessions/login'
	end
end

# delete post
delete '/post/:id' do
	if session[:id]
		@post = Post.find(params[:id])	
		if @post[:owner_id] == session[:id]
			@post = Post.find(params[:id])
			@post.destroy
			redirect '/'
		else
			erb :'eror/no_access'
		end
	else
		erb :'eror/no_access'
	end
end 

#-----PARSER-----

get '/update/index' do
	update_parser
	redirect '/'
end

class Parser
	attr_accessor :parse
end
	def update_parser
bitcoin = []

url = 'https://www.99cryptocoin.com/ru/?gclid=CjwKCAiAtorUBRBnEiwAfcp_Y6YwRiYWPj_JLiYyB7dCVKgz1aYV7vSrsmREh7dKLkdVuBu5qhG7XBoCjVcQAvD_BwE'
html = open(url)
doc = Nokogiri::HTML(html)

doc.css('tr').each do |line|
	n = line['data-href'].to_s.split('/').last
	pr = line.css('.js-format-price').text
	bitcoin.push(
	name: n,
	price: pr
	)
end
bitcoin.shift
File.write('storage/reviews.json', JSON.pretty_generate(bitcoin))
end

def get_parser
  file = File.read('storage/reviews.json')
  @parse.parse = JSON.parse(file)
end



