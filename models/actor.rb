require 'pry'

class Actor
  attr_reader :id, :name, :roles

  def initialize(id, name, roles = [])
    @id = id
    @name = name
    @roles = roles
  end

  def self.all
    @@all_actors = []
    actors = []

    db_connection do |conn|
      sql_query = %(
      SELECT actors.id, actors.name
      FROM actors
      ORDER BY actors.name ASC;
      )
      actors = conn.exec(sql_query)
    end

    actors.each do |a|
      if !@@all_actors.any? { |actor| actor.id == a['id']}
        @@all_actors << Actor.new(a['id'], a['name'])
      end
    end
    @@all_actors
  end

  def self.update_roles(actor_id)
    actors = []
    db_connection do |conn|
      sql_query = %(
      SELECT actors.id AS actor_id, actors.name, movies.id AS movie_id, cast_members.character
      FROM actors
      JOIN cast_members ON actors.id = cast_members.actor_id
      JOIN movies ON cast_members.movie_id = movies.id
      WHERE actors.id = $1
      ORDER BY actors.name ASC;
      )
      actors = conn.exec_params(sql_query, [actor_id])
    end

    actors.each do |actor|
      roles_hash = { actor['movie_id'] => actor['character'] }
      found_actor = Actor.find_actor(actor['actor_id'])
      Actor.add_roles(found_actor, roles_hash)
    end
  end

  def self.add_roles(actor_object, roles_hash)
    if !actor_object.roles.any? { |r| r.keys[0] == roles_hash.keys[0] && r.values[0] == roles_hash.values[0] }
      actor_object.roles << roles_hash
    end
  end

  def self.find_actor(actor_id)
    found_actor = @@all_actors.find { |actor| actor.id == actor_id }
    found_actor
  end



end
