return {
  name = "SovietKitsune/terrible-lite",
  version = "0.0.1",
  description = "Chaos",
  tags = { "chaos", "discordia" },
  license = "MIT",
  author = { name = "Soviet Kitsune", email = "sovietkitsune@soviet.solutions" },
  homepage = "https://github.com/SovietKitsune/terrible-lite",
  dependencies = {
    "SinisterRectus/discordia@2.8.4",
    "SinisterRectus/sqlite3@v1.0.0-1",
    "creationix/toml@v0.40.0"
  },
  files = {
    "**.lua",
    "!test*"
  }
}