module Model

    #om man sätter (params) så kallar du på hela dictionaryn och den kan inte sluta fungera om man byter från sinatra
    
    def login_values(params)
        db=SQLite3::Database.new('db/database.db')

        db.results_as_hash = true
        result = db.execute("SELECT * FROM users")
        
        i = 0
        while i <= result.length - 1
            if params["username"] == result[i][1]
                if BCrypt::Password.new(result[i][2]) == params["password"]
                    valid = true
                    params["User_id"] = result[i][0]
                    break
                else
                    valid = false
                end
            else
                valid = false
            end

            i += 1
        end

        p params
        
        return valid, params["User_id"]
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

    def get_username(params, x)
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true
        
        params["User_id"] = x
        return db.execute("SELECT users.Username FROM users WHERE UserId = ?", params["User_id"])
    end

    def get_posts
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true

        #returna bara istället för att tilldela en sessions variabel kan tilldela en variabel i controller.
        return db.execute("SELECT posts.Text, posts.PostId, posts.Upvotes, users.Username FROM posts INNER JOIN users ON users.UserId = posts.UserIdP")
    end

    def login_check(params, x)
        db=SQLite3::Database.new('db/database.db')

        db.results_as_hash = true
        result = db.execute("SELECT * FROM users")

        params["User_id"] = x

        k = 0
        
        while k <= result.length - 1
            if params["User_id"] == result[k][0]
                session[:logged_in] = true
                break
            else
                session[:logged_in] = false
            end
            
            k += 1
        end
    end

    def upload_post(params, x)
        db=SQLite3::Database.new('db/database.db')
        
        db.results_as_hash = true
        result = db.execute("SELECT * FROM posts")

        params["User_id"] = x

        db.execute("INSERT INTO posts (Text, UserIdP, Upvotes) VALUES (?,?,?)", params["p_text"], params["User_id"], 0)
    end

    def show_post
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true

        session[:post_id] = params["postId"]

        session[:UId_P] = db.execute("SELECT posts.UserIdP FROM posts WHERE PostId = ?", session[:post_id])
        session[:PostText] = db.execute("SELECT posts.Text FROM posts WHERE PostId = ?", session[:post_id])
        session[:upvotes] = db.execute("SELECT posts.Upvotes FROM posts WHERE PostId = ?", session[:post_id])
        session[:post_creator] = db.execute("SELECT users.Username FROM users WHERE UserId = ?", session[:UId_P][0]["UserIdP"])
    end

    def upvote_post
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true

        session[:current_upvotes] = db.execute("SELECT posts.Upvotes FROM posts WHERE postId = ?", session[:post_id])

        session[:new_upvotes] = session[:current_upvotes][0]["Upvotes"].to_i + 1

        db.execute("UPDATE posts SET Upvotes = ? WHERE postId = ?", session[:new_upvotes], session[:post_id])
    end

    def downvote_post
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true

        session[:current_upvotes] = db.execute("SELECT posts.Upvotes FROM posts WHERE postId = ?", session[:post_id])

        session[:new_upvotes] = session[:current_upvotes][0]["Upvotes"].to_i - 1

        db.execute("UPDATE posts SET Upvotes = ? WHERE postId = ?", session[:new_upvotes], session[:post_id])
    end

    def upvote_post_i
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true

        session[:current_upvotes] = db.execute("SELECT posts.Upvotes FROM posts WHERE postId = ?", params["postId"])

        session[:new_upvotes] = session[:current_upvotes][0]["Upvotes"].to_i + 1

        db.execute("UPDATE posts SET Upvotes = ? WHERE postId = ?", session[:new_upvotes], params["postId"])
    end

    def downvote_post_i
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true

        session[:current_upvotes] = db.execute("SELECT posts.Upvotes FROM posts WHERE postId = ?", params["postId"])

        session[:new_upvotes] = session[:current_upvotes][0]["Upvotes"].to_i - 1

        db.execute("UPDATE posts SET Upvotes = ? WHERE postId = ?", session[:new_upvotes], params["postId"])
    end

    def edit_post
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true

        session[:new_text] = params["e_text"]

        db.execute("UPDATE posts SET Text = ? WHERE postId = ?", session[:new_text], session[:post_id])
    end

    def remove_post
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true

        db.execute("DELETE FROM posts WHERE postId = ?", session[:post_id])
    end
end