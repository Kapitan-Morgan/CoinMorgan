require 'sinatra'
require 'sinatra/flash'
require 'open-uri'
require 'nokogiri'
require 'json'
require 'bcrypt'
require 'rest-client'
require 'sinatra/activerecord'
require "./models/posts.rb"
require "./models/users.rb"
require './helpers/user_helper.rb'

enable :sessions

before do
	@current_user = current_user
	get_parser
end

#-----ГЛАВНАЯ-----
get '/' do
	#@user = User.find(session[:id]) if session[:id]
	@parse = Parser.new
	get_parser
	erb :index
end

#-----POST-----

#Просмотр постов пользователя
get "/posts" do
	if @current_user
		@posts = @current_user.posts
		erb :'posts/show'
	else
		flash.now[:warning] = 'Для просмотра войдите в систему'
		erb :'users/login'
	end
end
#-----ПРОСМОТР КОНКРЕТНОГО ПОСТА-----
get '/posts/:id' do
	if @current_user
		ps = @current_user.posts
		@post = ps.find(params[:id]) rescue nil
		unless @post.nil?
		if @post[:user_id] == session[:id]
			erb :post_page
		else
			flash.now[:warning] = 'Нет доступа!'
			erb :index
		end
	else
		flash.now[:warning] = 'Такого поста не существует'
		erb :index
	end
	else
		flash.now[:warning] = 'Войдите в систему!'
		erb :'users/login'
	end
end
#-----ИЗМЕНЕНИЕ ПОСТА-----
put '/posts/:id/edit' do
	if session[:id]
		@post = Post.find(params[:id])
		if @post[:user_id] == session[:id]
			@post.update(name: params[:name], number: params[:number], price_by: params[:price_by])
			@post.save
			flash[:succes] = 'Запись успешно изменена'
			redirect '/posts'
		else
			flash.now[:warning] = 'Нет доступа!'
			erb :index
		end
	else
		flash.now[:warning] = 'Войдите в систему'
		erb :'/users/login'
	end
end
#-----ВЬЮХА СОЗДАНИЯ ПОСТА-----
get '/posts/new' do
	if @current_user
		@parse = Parser.new
	    get_parser
		erb :create
	else
		flash.now[:warning] = 'Для добавление новых записей войдите в свой аккаунт'
		erb :'users/login'
	end
end

#-----КОНТРОЛЛЕР СОЗДАНИЯ ПОСТА-----
post '/post' do
	if @current_user
		@post = Post.create(name: params[:name].downcase, number: params[:number], price_by: params[:price_by] , user_id: @current_user[:id])
		flash[:succes] = 'Монета добавленна в ваш крипто портфель'
		redirect '/posts'
	else
		flash.now[:warning] = 'Для добавление новых записей войдите в свой аккаунт'
		erb :'users/login'
	end
end

#-----УДАЛЕНИЕ ПОСТА-----
delete '/post/:id' do
	if @current_user
		@post = Post.find(params[:id])
		if @post[:user_id] == session[:id]
			@post = Post.find(params[:id])
			@post.destroy
			flash[:succes] = 'Пост успешно удален'
			redirect '/posts'
		else
			flash.now[:warning] = 'Нет доступа!'
			erb :index
		end
	else
		flash.now[:warning] = 'Для удаления записей войдите в свой аккаунт'
		erb :'users/login'
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
			flash.now[:warning] = 'Данное имя уже занято!'
			erb :registrations
		end
	else
		flash.now[:warning] = 'Поля "password" может быть пустым!'
		erb :registrations
	end
	else
		flash.now[:warning] = 'Поля "email" не может быть пустым!'
		erb :registrations
	end
	else
		flash.now[:warning] = 'Поле "name" не может быть пустым!'
		erb :registrations
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
		flash.now[:notice] = 'Нам не удалось подтвердить ваши данные. Проверьте их ещё раз и попробуйте снова.'
		erb :'users/login'
  end
end
#-----ВЫХОД ИЗ СЕССИИ-----
get '/sessions/logout' do
	session.clear
	redirect '/'
end
#-----ДОМАШНЯЯ СТРАНИЦА ПОЛЬЗОВАТЕЛЯ
get '/users/:id' do
	#@user = User.find(session[:id]) if session[:id]
	erb :'users/home'
end
#-----ВЬЮХА РЕГИСТРАЦИИИ-----
get '/users/signup' do
	#@user = User.find(session[:id]) if session[:id]
	erb :registrations
end
#-----ВЬЮХА ВХОДА В АККАУНТ-----
get '/users/login' do
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

url = 'https://www.worldcoinindex.com'
html = open(url)
doc = Nokogiri::HTML(html)

doc.css('.coinzoeken').each do |line|
    id = line.css('.rank').text
    name = line.at_css('h1 span').text
    price = line.css('.span').first.text
    price = price.to_s.gsub(',', '').to_f
    percent = line.css('.percentage').text
    if line.css('.percentage').to_s.include?('red')
      color = 'red'
    else
      color = 'green'
    end
    volue = line.css('.volume').text.strip.delete(' ')
    market_cap = line.css('.span').pop.text
	bitcoin.push(
	id: id,
	name: name,
	price: price,
    color: color,
    percent: percent,
    volue: volue,
    market_cap: market_cap
	)
end
File.write('storage/reviews.json', JSON.pretty_generate(bitcoin))
end

def get_parser
  file = File.read('storage/reviews.json')
  @parse = Parser.new
  @parse.parse = JSON.parse(file)
end


#ERRORS

def not_found
  raise ActiveRecord::RecordNotFound.new('Not Found')
	erb :'eror/no_access'
end
