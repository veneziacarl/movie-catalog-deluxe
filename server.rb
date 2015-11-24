require "sinatra"
require "pg"
require_relative 'models/actor'
require_relative 'models/movie'
require 'pry'

configure :development do
  set :db_config, { dbname: "movies" }
end

configure :test do
  set :db_config, { dbname: "movies_test" }
end

def db_connection
  begin
    connection = PG.connect(Sinatra::Application.db_config)
    yield(connection)
  ensure
    connection.close
  end
end

Actor.all
Movie.all

get '/actors' do
  @actors = Actor.all
  erb :actor_index
end

get '/actors/:id' do
  @actor_id = params[:id]
  Actor.update_roles(@actor_id)
  @actor = Actor.find_actor(@actor_id)
  @all_movies_and_characters = []
  @actor.roles.each do |movie|
    @all_movies_and_characters << [Movie.find_movie(movie.keys[0]), movie.values[0]]
  end
  erb :actor_show
end

get '/movies' do
  @movies = Movie.all
  erb :movie_index
end
# 
# post '/movies' do
#   @order = params[:order]
# end

get '/movies/:id' do
  @movie_id = params[:id]
  # Movie.update_roles(@movie_id)
  @movie = Movie.find_movie(@movie_id)
  @cast_members = []
  @movie.find_cast.each do |cast|
    @cast_members << Actor.find_actor(cast)
  end
  erb :movie_show
end
