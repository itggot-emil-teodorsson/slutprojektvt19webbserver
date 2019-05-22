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

    def register_values(params)
        db=SQLite3::Database.new('db/database.db')
        
        db.results_as_hash = true
        usernames = db.execute("SELECT * FROM users")

        if params["reg_password"] == params["rereg_password"]

            username_taken = false
            j = 0
            while j <= usernames.length - 1
                if params["reg_username"] == usernames[j][1]
                    username_taken = true
                end
                j += 1
            end

            if username_taken == false
                hash_password = BCrypt::Password.create(params["reg_password"])
                db.execute("INSERT INTO users (Username, Password) VALUES (?,?)", params["reg_username"], hash_password)
                
                taken_username = false
            else
                taken_username = true
            end
            reg_complete = true
        else
            reg_complete = false
        end

        return reg_complete, taken_username
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
                params["logged_in"] = true
                break
            else
                params["logged_in"] = false
            end
            
            k += 1
        end

        return params["logged_in"]
    end

    def upload_post(params, x)
        db=SQLite3::Database.new('db/database.db')
        
        db.results_as_hash = true
        result = db.execute("SELECT * FROM posts")

        params["User_id"] = x

        db.execute("INSERT INTO posts (Text, UserIdP, Upvotes) VALUES (?,?,?)", params["p_text"], params["User_id"], 0)
    end

    def show_post(params)
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true

        params["UId_P"] = db.execute("SELECT posts.UserIdP FROM posts WHERE PostId = ?", params["postId"])
        params["PostText"] = db.execute("SELECT posts.Text FROM posts WHERE PostId = ?", params["postId"])
        params["upvotes"] = db.execute("SELECT posts.Upvotes FROM posts WHERE PostId = ?", params["postId"])
        params["post_creator"] = db.execute("SELECT users.Username FROM users WHERE UserId = ?", params["UId_P"][0]["UserIdP"])

        return params["PostText"], params["post_creator"], params["upvotes"], params["UId_P"], params["postId"]
    end

    def upvote_post(params, x)
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true

        params["post_id"] = x

        current_upvotes = db.execute("SELECT posts.Upvotes FROM posts WHERE postId = ?", params["post_id"])

        new_upvotes = current_upvotes[0]["Upvotes"].to_i + 1

        db.execute("UPDATE posts SET Upvotes = ? WHERE postId = ?", new_upvotes, params["post_id"])
    end

    def downvote_post(params, x)
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true

        params["post_id"] = x

        current_upvotes = db.execute("SELECT posts.Upvotes FROM posts WHERE postId = ?", params["post_id"])

        new_upvotes = current_upvotes[0]["Upvotes"].to_i - 1

        db.execute("UPDATE posts SET Upvotes = ? WHERE postId = ?", new_upvotes, params["post_id"])
    end

    def upvote_post_i(params)
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true

        current_upvotes = db.execute("SELECT posts.Upvotes FROM posts WHERE postId = ?", params["postId"])

        new_upvotes = current_upvotes[0]["Upvotes"].to_i + 1

        db.execute("UPDATE posts SET Upvotes = ? WHERE postId = ?", new_upvotes, params["postId"])
    end

    def downvote_post_i(params)
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true

        current_upvotes = db.execute("SELECT posts.Upvotes FROM posts WHERE postId = ?", params["postId"])

        new_upvotes = current_upvotes[0]["Upvotes"].to_i - 1

        db.execute("UPDATE posts SET Upvotes = ? WHERE postId = ?", new_upvotes, params["postId"])
    end

    def edit_post(params, x)
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true

        params["post_id"] = x

        db.execute("UPDATE posts SET Text = ? WHERE postId = ?", params["e_text"], params["post_id"])
    end

    def remove_post(params, x)
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true

        params["post_id"] = x

        db.execute("DELETE FROM posts WHERE postId = ?", params["post_id"])
    end
end