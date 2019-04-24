require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative 'model.rb'

enable :sessions

before('/') do
    get_username
end

get('/') do
    slim(:index, locals:{users:session[:result]})
end

get('/registrera') do
    slim(:register)
end

post('/register_values') do
    register_values
    if session[:reg_complete] == true
        if session[:taken_username] == false
            redirect('/reg_complete')
        else
            redirect('/username_taken')
        end
    else
        redirect('/reg_failed')
    end
end

get('/reg_complete') do
    slim(:reg_complete)
end

get('/reg_failed') do
    slim(:reg_failed)
end

get('/username_taken') do
    slim(:username_taken)
end

get('/logga_in') do
    slim(:login)
end

post('/login_values') do
    login_values(params["username"], params["password"])
    if session[:valid] == true
        redirect('/')
    else 
        redirect('/no_access')
    end
end

get('/no_access') do
    slim(:no_access)
end

get('/logga_ut') do
    session[:User_id] = nil
    redirect('/')
end