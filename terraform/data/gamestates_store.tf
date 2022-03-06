resource "upstash_redis_database" "redis" {
  database_name = "gamestate"
  region = "us-east-1"
  tls = "true"
  multizone = "false"
}

data "upstash_redis_database_data" "redis_data" {
    database_id = resource.upstash_redis_database.redis.database_id
}

