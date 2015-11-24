class Movie
  attr_reader :id, :title, :year, :rating, :genre, :studio

  def initialize(id, title, year, rating, genre, studio, actors = [])
    @id = id
    @title = title
    @year = year
    @rating = rating
    @genre = genre
    @studio = studio
    @actors = actors
  end

  def self.all
    @@all_movies = []
    movies = []

    db_connection do |conn|
      sql_query = %(
      SELECT movies.id, movies.title, movies.year, movies.rating, genres.name AS genre, studios.name AS studio
      FROM movies
      LEFT JOIN genres ON movies.genre_id = genres.id
      LEFT JOIN studios ON movies.studio_id = studios.id
      ORDER BY movies.title ASC;
      )
      movies = conn.exec(sql_query)
    end

    movies.each do |m|
      if !@@all_movies.any? { |movie| movie.id == m['id']}
        @@all_movies << Movie.new(m['id'], m['title'], m['year'], m['rating'], m['genre'], m['studio'])
      end
    end
    @@all_movies
  end

  def self.find_movie(movie_id)
    found_movie = @@all_movies.find { |movie| movie.id == movie_id }
    found_movie
  end

  def find_cast
    actors = []
    db_connection do |conn|
      sql_query = %(
      SELECT actors.id AS actor_id, actors.name, movies.id AS movie_id, cast_members.character
      FROM actors
      JOIN cast_members ON actors.id = cast_members.actor_id
      JOIN movies ON cast_members.movie_id = movies.id
      WHERE movies.id = $1
      ORDER BY actors.name ASC;
      )
      actors = conn.exec_params(sql_query, [id])
    end

    cast_members = []
    actors.each do |actor|
      cast_members << actor['actor_id']
    end
    cast_members
  end
end
