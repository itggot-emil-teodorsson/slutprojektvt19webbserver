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

    session[:reg_username] = params["reg_username"]
    session[:reg_password] = params["reg_password"]

    session[:hash_password] = BCrypt::Password.create(session[:reg_password])

    db.execute("INSERT INTO users (Username, Password) VALUES (?,?)", session[:reg_username], session[:hash_password])
end