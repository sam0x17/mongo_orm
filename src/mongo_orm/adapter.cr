require "mongo"
class Mongo::ORM::Adapter
  property client : Mongo::Client
  DATABASE_YML = "config/database.yml"

  def initialize
    database_url : String = "mongodb://localhost:27017"
    if ENV["DATABASE_URL"]?
      database_url = ENV["DATABASE_URL"]
    elsif File.exists?("config/database.yml")
      yaml = YAML.parse(File.read DATABASE_YML)
      database_url = yaml["database_url"].to_s
    end
    @client = Mongo::Client.new database_url
  end
end
