require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative 'model.rb'

enable :sessions


before('/') do
    get_username
    get_posts
end

get('/') do
    slim(:index, locals:{users:session[:result], posts:session[:post_text]})
end

get('/u_vote_i/:postId') do
    upvote_post_i
    redirect back
end

get('/d_vote_i/:postId') do
    downvote_post_i
    redirect back
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

before('/skapa_inlagg') do
    login_check
end

get('/skapa_inlagg') do
    if session[:logged_in] == true
        slim(:skapa_inlagg)
    else
        slim(:no_profile)
    end
end

post('/uploading_post') do
    upload_post
    redirect('/')
end

get('/show_post/:postId') do
    show_post
    slim(:show_post, locals:{post_content:session[:PostText], post_user:session[:post_creator], post_upvotes:session[:upvotes], post_userid:session[:UId_P]})
end

get('/u_vote/:post_id') do
    upvote_post
    redirect back
end

get('/d_vote/:post_id') do
    downvote_post
    redirect back
end

get('/edit_post/:post_id') do
    slim(:edit_post)
end

post('/uploading_edit') do
    edit_post
    redirect('/')
end

