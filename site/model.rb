# The file with all of the functions
module Model
    
    # Attempts to log in a user
    #
    # @param [Hash] params form data
    # @option params [String] username The username
    # @option params [String] password The password
    #
    # @return [Hash]
    #   * valid [Boolean] whether the given login info is valid or not
    #   * user_id [Integer] The user's ID if they were successfully logged in
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
        
        return valid, params["User_id"]
    end

    # Attempts to create a new user
    #
    # @param [Hash] params form data
    # @option params [String] reg_username The username
    # @option params [String] reg_password The password
    # @option params [String] rereg_password The repeated password
    #
    # @return [Hash]
    #   * different_passwords [Boolean] whether the password and the repeated password are the same or not
    #   * username_taken [Boolean] whether the username you're trying to register already has been registered or not
    #   * empty_form [Boolean] whether a part of the form is empty or not
    def register_values(params)
        db=SQLite3::Database.new('db/database.db')
        
        db.results_as_hash = true
        usernames = db.execute("SELECT * FROM users")

        if params["reg_username"] != ""
            empty_form = false
            if params["reg_password"] != ""
                empty_form = false
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
                    end
                    different_passwords = true
                else
                    different_passwords = false
                end
            else
                empty_form = true
            end
        else
            empty_form = true
        end

        return different_passwords, username_taken, empty_form
    end

    # Attempts to acquire the username of the user that is currently logged in
    #
    # @param [Hash] params Calls on the dictionary
    # @param [Integer] user_id The user's ID
    #
    # @return [Hash]
    #   * username [String] The wanted username
    def get_username(params, user_id)
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true
        
        params["User_id"] = user_id
        username = db.execute("SELECT users.Username FROM users WHERE UserId = ?", params["User_id"])

        return username
    end

    # Acquires all of the posts
    #
    # @return [Hash]
    #   * posts [Array] A list of all posts
    def get_posts
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true

        posts = db.execute("SELECT posts.Text, posts.PostId, posts.Upvotes, users.Username FROM posts INNER JOIN users ON users.UserId = posts.UserIdP")

        return posts
    end

    # Checks whether you are logged in or not
    #
    # @param [Hash] params Calls on the dictionary
    # @param [Integer] user_id The user's ID
    #
    # @return [Hash]
    #   * logged_in [Boolean] whether the user is logged in or not
    def login_check(params, user_id)
        db=SQLite3::Database.new('db/database.db')

        db.results_as_hash = true
        result = db.execute("SELECT * FROM users")

        params["User_id"] = user_id

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

    # Attemts to insert a new row in the posts table
    #
    # @param [Hash] params form data
    # @option params [String] p_text The post's text
    # @param [Integer] user_id The user's ID
    def upload_post(params, user_id)
        db=SQLite3::Database.new('db/database.db')
        
        db.results_as_hash = true
        result = db.execute("SELECT * FROM posts")

        params["User_id"] = user_id

        db.execute("INSERT INTO posts (Text, UserIdP, Upvotes) VALUES (?,?,?)", params["p_text"], params["User_id"], 0)
    end

    # Shows an individual post
    #
    # @param [Hash] params form data
    # @option params [Integer] postId The post's ID
    #
    # @return [Hash]
    #   * PostText [String] The post's text
    #   * post_creator [String] The name of the user who created the post
    #   * upvotes [Integer] The ammount of upvotes that the post has
    #   * UId_P [Integer] The creator's ID
    #   * postId [Integer] The post's ID
    def show_post(params)
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true

        params["UId_P"] = db.execute("SELECT posts.UserIdP FROM posts WHERE PostId = ?", params["postId"])
        params["PostText"] = db.execute("SELECT posts.Text FROM posts WHERE PostId = ?", params["postId"])
        params["upvotes"] = db.execute("SELECT posts.Upvotes FROM posts WHERE PostId = ?", params["postId"])
        params["post_creator"] = db.execute("SELECT users.Username FROM users WHERE UserId = ?", params["UId_P"][0]["UserIdP"])

        return params["PostText"], params["post_creator"], params["upvotes"], params["UId_P"], params["postId"]
    end

    # Upvotes a specific post when you show it individually
    #
    # @param [Hash] params Calls on the dictionary
    def upvote_post(params)
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true

        current_upvotes = db.execute("SELECT posts.Upvotes FROM posts WHERE postId = ?", params["post_id"])

        new_upvotes = current_upvotes[0]["Upvotes"].to_i + 1

        db.execute("UPDATE posts SET Upvotes = ? WHERE postId = ?", new_upvotes, params["post_id"])
    end

    # Downvotes a specific post when you show it individually
    #
    # @param [Hash] params Calls on the dictionary
    def downvote_post(params)
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true

        current_upvotes = db.execute("SELECT posts.Upvotes FROM posts WHERE postId = ?", params["post_id"])

        new_upvotes = current_upvotes[0]["Upvotes"].to_i - 1

        db.execute("UPDATE posts SET Upvotes = ? WHERE postId = ?", new_upvotes, params["post_id"])
    end

    # Upvotes a specific post from the main page
    #
    # @param [Hash] params form data
    # @option params [Integer] postId The post's ID
    def upvote_post_i(params)
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true

        current_upvotes = db.execute("SELECT posts.Upvotes FROM posts WHERE postId = ?", params["postId"])

        new_upvotes = current_upvotes[0]["Upvotes"].to_i + 1

        db.execute("UPDATE posts SET Upvotes = ? WHERE postId = ?", new_upvotes, params["postId"])
    end

    # Downvotes a specific post from the main page
    #
    # @param [Hash] params form data
    # @option params [Integer] postId The post's ID
    def downvote_post_i(params)
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true

        current_upvotes = db.execute("SELECT posts.Upvotes FROM posts WHERE postId = ?", params["postId"])

        new_upvotes = current_upvotes[0]["Upvotes"].to_i - 1

        db.execute("UPDATE posts SET Upvotes = ? WHERE postId = ?", new_upvotes, params["postId"])
    end

    # Updates a row in the posts table
    #
    # @param [Hash] params form data
    # @option params [String] e_text The new text in the post
    # @param [Integer] post_id The post's ID
    def edit_post(params, post_id)
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true

        params["post_id"] = post_id

        db.execute("UPDATE posts SET Text = ? WHERE postId = ?", params["e_text"], params["post_id"])
    end

    # Deletes a row from the posts table
    #
    # @param [Hash] params Calls on the dictionary
    # @param [Integer] post_id The post's ID
    def remove_post(params)
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true

        db.execute("DELETE FROM posts WHERE postId = ?", params["post_id"])
    end
end