require 'sinatra'
require 'open-uri'
require 'nokogiri'
require 'json'
require 'bcrypt'
require 'sinatra/activerecord'
require "./models/models.rb"
require "./models/users.rb"
require './helpers/user_helper.rb'

enable :sessions
before do
	@parse = Parser.new
	get_parser
end
#-----ГЛАВНАЯ-----
get '/' do
	current_user
	#@user = User.find(session[:id]) if session[:id]
	@parse = Parser.new
	get_parser
	erb :index
end

#-----POST-----

#Просмотр постов пользователя
get "/posts/show" do
	if session[:id]
		@parse = Parser.new
	    get_parser
		@user = User.find(session[:id])
		a = Post.all
		@posts = a.find_all{|e| e[:owner_id] == @user[:id]}
		erb :'posts/show'
	else 
		erb :'users/login'
	end
end
#-----ПРОСМОТР КОНКРЕТНОГО ПОСТА-----
get '/post/:id' do
	if session[:id]
		@post = Post.find(params[:id])
		if @post[:owner_id] == session[:id]
			@post = Post.find(params[:id])
			erb :post_page
		else
			erb :'eror/no_access'
		end
	else
		erb :'eror/no_access'
	end
end
#-----ИЗМЕНЕНИЕ ПОСТА-----
put '/post/:id' do
	if session[:id]
		@post = Post.find(params[:id])
		if @post[:owner_id] == session[:id]
			@post.update(name: params[:name], number: params[:number], price_by: params[:price_by])
			@post.save
			redirect '/posts/show'
		else
			erb :'eror/no_access'
		end
	else
		erb :'/sessions/login'
	end
end
#-----ВЬЮХА СОЗДАНИЯ ПОСТА-----
get '/create' do
	if session[:id]
		@user = User.find(session[:id]) if session[:id]
		@parse = Parser.new
	    get_parser
		erb :create
	else 
		erb :'users/login'
	end
end

#-----КОНТРОЛЛЕР СОЗДАНИЯ ПОСТА-----
post '/post' do
	if session[:id]
		@user = User.find(session[:id])
		@post = Post.create(name: params[:name].downcase, number: params[:number], price_by: params[:price_by] , owner_id: @user[:id])
		redirect '/posts/show'
	else
		erb :'/sessions/login'
	end
end

#-----УДАЛЕНИЕ ПОСТА-----
delete '/post/:id' do
	if session[:id]
		@post = Post.find(params[:id])	
		if @post[:owner_id] == session[:id]
			@post = Post.find(params[:id])
			@post.destroy
			redirect '/posts/show'
		else
			erb :'eror/no_access'
		end
	else
		erb :'eror/no_access'
	end
end 

#-----USER-----

#-----РЕГИСТРАЦИЯ ПОЛЬЗОВАТЕЛЯ-----
post '/registrations' do
	unless params[:username].empty?
	unless params[:email].empty?
	unless params[:password].empty?
		a = User.find_by(username: params[:username])
		b = User.find_by(email: params[:email])
		unless a || b
			@user = User.create(username: params[:username], password: params[:password], password_confirmation: params[:confirm_password], email: params[:email])
			session[:id] = @user.id
			redirect '/users/home'
		else
			erb :'eror/dont_name'
		end
	else
		erb :'eror/params'
	end
	else
		erb :'eror/params'
	end
	else
		erb :'eror/params'
	end
end
#-----ВХОД В АККАУНТ-----
post '/sessions' do
	user = User.find_by(email: params[:email])
  if user && user.authenticate(params[:password])
  	puts '------'
   session[:id] = user.id
   redirect to '/'
	else
		erb :'eror/session_eror'
  end
end
#-----ВЫХОД ИЗ СЕССИИ-----
get '/sessions/logout' do
	session.clear
	redirect '/'
end
#-----ДОМАШНЯЯ СТРАНИЦА ПОЛЬЗОВАТЕЛЯ
get '/users/home' do
	#@user = User.find(session[:id]) if session[:id]
	erb :'users/home'
end
#-----ВЬЮХА РЕГИСТРАЦИИИ-----
get '/registrations/signup' do
	#@user = User.find(session[:id]) if session[:id]
	erb :registrations
end
#-----ВЬЮХА ВХОДА В АККАУНТ-----
get '/sessions/login' do
	#@user = User.find(session[:id]) if session[:id]
	puts session
	erb :'users/login'
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
i = 0
doc.css('tr').each do |line|
	n = line['data-href'].to_s.split('/').last
	pr = line.css('.js-format-price').text
	bitcoin.push(
	id: i,
	name: n,
	price: pr
	)
	i+=1
end
bitcoin.shift
File.write('storage/reviews.json', JSON.pretty_generate(bitcoin))
end

def get_parser
  file = File.read('storage/reviews.json')
  @parse.parse = JSON.parse(file)
end



