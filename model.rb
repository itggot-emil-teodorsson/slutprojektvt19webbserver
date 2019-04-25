require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions

def login_values(x, y)
    db=SQLite3::Database.new('db/database.db')

    db.results_as_hash = true
    result = db.execute("SELECT * FROM users")

    session[:username] = x
    session[:password] = y
    
    i = 0
    while i <= result.length - 1
        if session[:username] == result[i][1]
            if BCrypt::Password.new(result[i][2]) == session[:password]
                session[:valid] = true
                session[:User_id] = result[i][0]
                break
            else
                session[:valid] = false
            end
        else
            session[:valid] = false
        end

        i += 1
    end
    
    return session[:valid]
end

def register_values
    db=SQLite3::Database.new('db/database.db')
    
    db.results_as_hash = true
    usernames = db.execute("SELECT * FROM users")

    session[:reg_username] = params["reg_username"]
    session[:reg_password] = params["reg_password"]
    session[:rereg_password] = params["rereg_password"]

    if session[:reg_password] == session[:rereg_password]

        username_taken = false
        j = 0
        while j <= usernames.length - 1
            if session[:reg_username] == usernames[j][1]
                username_taken = true
            end
            j += 1
        end

        if username_taken == false
            session[:hash_password] = BCrypt::Password.create(session[:reg_password])
            db.execute("INSERT INTO users (Username, Password) VALUES (?,?)", session[:reg_username], session[:hash_password])
            
            session[:taken_username] = false
        else
            session[:taken_username] = true
        end
        session[:reg_complete] = true
    else
        session[:reg_complete] = false
    end
end

def get_username
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
        
    session[:result] = db.execute("SELECT users.Username FROM users WHERE UserId = ?", session[:User_id])
end

def get_posts
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    
    session[:post_text] = db.execute("SELECT posts.Text, posts.PostId, users.Username FROM posts INNER JOIN users ON users.UserId = posts.UserId_P")
end

def login_check
    db=SQLite3::Database.new('db/database.db')

    db.results_as_hash = true
    result = db.execute("SELECT * FROM users")

    k = 0
    
    while k <= result.length - 1
        if session[:User_id] == result[k][0]
            session[:logged_in] = true
            break
        else
            session[:logged_in] = false
        end
        
        k += 1
    end
end

def upload_post
    db=SQLite3::Database.new('db/database.db')
    
    db.results_as_hash = true
    result = db.execute("SELECT * FROM posts")

    session[:text] = params["p_text"]

    db.execute("INSERT INTO posts (Text, UserId_P, Upvotes) VALUES (?,?,?)", session[:text], session[:User_id], 0)
end

def show_post
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true

    session[:post_id] = params["postId"]

    session[:PostText] = db.execute("SELECT posts.Text FROM posts WHERE PostId = ?", session[:post_id])
    session[:post_creator] = db.execute("SELECT users.Username FROM users WHERE UserId = ?", session[:post_id])
end