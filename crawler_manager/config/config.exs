import Config

config :logger,
  backends: [:console],
  compile_time_purge_level: :debug

config :logger, :console,
  format: "\n#### $time $metadata[$level] $levelpad$message\n\n",
  metadata: :all
