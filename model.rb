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