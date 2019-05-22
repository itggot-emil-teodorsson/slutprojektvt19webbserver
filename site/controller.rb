require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative 'model.rb'
include Model

enable :sessions


before('/') do
    session[:result] = get_username(params, session[:User_id])
    session[:post_text] = get_posts
end

# Display Landing Page
#
get('/') do
    slim(:index, locals:{users:session[:result], posts:session[:post_text]})
end

# Calls on a function which upvotes the post and redirects to '/'
#
# @see Model#upvote_post_i
get('/u_vote_i/:postId') do
    upvote_post_i(params)
    redirect back
end

# Calls on a function which downvotes the post in question
#
# @see Model#downvote_post_i
get('/d_vote_i/:postId') do
    downvote_post_i(params)
    redirect back
end

# Displays a register form
#
get('/registrera') do
    slim(:register)
end

# Attempts to register login values
#
# @see Model#register_values
post('/register_values') do
    reg_and_taken = register_values(params)
    if reg_and_taken[2] == false
        if reg_and_taken[0] == true
            if reg_and_taken[1] == false
                redirect('/reg_complete')
            else
                redirect('/username_taken')
            end
        else
            redirect('/reg_failed')
        end
    else
        redirect('/form_empty')
    end
end

# Displays a page that tells you that you succeded in registering
#
get('/reg_complete') do
    slim(:reg_complete)
end

# Displays an error message
#
get('/reg_failed') do
    slim(:reg_failed)
end

# Displays an error message
#
get('/username_taken') do
    slim(:username_taken)
end

# Displays an error message
#
get('/form_empty') do
    slim(:form_empty)
end

# Displays a login form
#
get('/logga_in') do
    slim(:login)
end

# Compares the values that you've tried to log in with, with the values that exist in the database and then redirects to either '/' or '/no_access'
#
# @see Model#login_values
post('/login_values') do
    valid = login_values(params)[0]
    session[:User_id] = login_values(params)[1]
    p valid
    if valid == true
        redirect('/')
    else 
        redirect('/no_access')
    end
end

# Displays an error message
#
get('/no_access') do
    slim(:no_access)
end

# Makes it so that you log out and redirects to '/'
#
get('/logga_ut') do
    session[:User_id] = nil
    redirect('/')
end

before('/skapa_inlagg') do
    session[:logged_in] = login_check(params, session[:User_id])
end

# Displays a form, if you're logged in
#
get('/skapa_inlagg') do
    if session[:logged_in] == true
        slim(:skapa_inlagg)
    else
        slim(:no_profile)
    end
end

# Attempts to insert the form-values in the database
#
# @see Model#upload_post
post('/uploading_post') do
    upload_post(params, session[:User_id])
    redirect('/')
end

# Displays an individual post
#
# @see Model#show_post
get('/show_post/:postId') do
    values = show_post(params)
    session[:post_id] = show_post(params)[4]
    slim(:show_post, locals:{post_content:values[0], post_user:values[1], post_upvotes:values[2], post_userid:values[3]})
end

# Calls on a function that upvotes the post when showing a single post and redirects back to '/show_post/:postId'
#
# @see Model#upvote_post
get('/u_vote/:post_id') do
    upvote_post(params, session[:post_id])
    redirect back
end

# Calls on a function that downvotes the post when showing a single post and redirects back to '/show_post/:postId'
#
# @see Model#downvote_post
get('/d_vote/:post_id') do
    downvote_post(params, session[:post_id])
    redirect back
end

# Displays a form for editing your post
#
get('/edit_post') do
    slim(:edit_post)
end

# Updates an existing post and redirects to '/'
#
# @see Model#edit_post
post('/uploading_edit') do
    edit_post(params, session[:post_id])
    redirect('/')
end

# Deletes an existing post and redirects to '/remove_confirmed'
#
# @see Model#remove_post
get('/remove_post/:post_id') do
    remove_post(params, session[:post_id])
    redirect('/remove_confirmed')
end

# Displays a page that tells you that you've succesfully removed a post
#
get('/remove_confirmed') do
    slim(:remove_confirmed)
end