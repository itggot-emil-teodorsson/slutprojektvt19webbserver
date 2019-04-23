require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative 'model.rb'

enable :sessions

get('/') do
    slim(:index)
end

get('/registrera') do
    slim(:register)
end

post('/register_values') do
    register_values
    redirect('/reg_complete')
end

get('/reg_complete') do
    slim(:reg_complete)
end

get('/logga_in') do
    slim(:login)
end

post('/login_values') do
    login_values(params["username"], params["password"])
    if session[:valid] == true
        redirect('/access')
    else 
        redirect('/no_access')
    end
end

get('/access') do
    slim(:access)
end

get('/no_access') do
    slim(:no_access)
end