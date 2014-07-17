require "sinatra"
require "gschool_database_connection"
# require "rack-flash"

class App < Sinatra::Application
  enable :sessions

  def initialize
    super
    @database_connection = GschoolDatabaseConnection::DatabaseConnection.establish(ENV["RACK_ENV"])
  end

  get "/" do
    # if current_user
    #   erb :signed_in, locals: {username: current_user[:username]}
    # else
    erb :root
  end

  post "/" do
    username = params[:username]
    password = params[:password]
    if username == "" && password == ""
      flash[:notice] = "No username or password entered"
      redirect '/'
    elsif password == ""
      flash[:notice] = "No password entered"
      redirect '/'
    elsif username == ""
      flash[:notice] = "No username entered"
      redirect '/'
    elsif @database_connection.sql("SELECT username, password from users where username = '#{username}' and password = '#{password}'") == []
      flash[:notice] = "Incorrect Username and Password"
      redirect '/'
    else

      erb :signed_in, :locals => {:username => username}
    end
  end



  get "/login" do
    erb :login
  end

  get "/register" do
    erb :register
  end

  post "/register" do
    username = params[:username]
    password = params[:password]
    email = params[:email]

    @database_connection.sql("INSERT INTO users (username, password, email) values ('#{username}', '#{password}', '#{email}')")
    # flash[:notice] = "Thank you for registering"
    redirect '/'
  end

  post "/sessions" do
    user = find_user(params)
    session[:user_id] = user[:id] if user
    redirect "/"
  end
end

