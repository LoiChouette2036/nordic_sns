# Specifies the number of threads per worker. Default: 5.
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }.to_i
threads threads_count, threads_count

# Specifies the number of workers. Use 2 for better concurrency.
workers ENV.fetch("WEB_CONCURRENCY") { 2 }.to_i

# Specifies the port that Puma will listen on.
port ENV.fetch("PORT") { 3000 }

# Specifies the environment.
environment ENV.fetch("RAILS_ENV") { "production" }

# Specifies the PID file location.
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# Specifies the state file location.
state_path ENV.fetch("STATEFILE") { "tmp/pids/puma.state" }

# Specifies the location of logs.
stdout_redirect "log/puma.stdout.log", "log/puma.stderr.log", true

# Allow puma to be restarted by `bin/rails restart` command.
plugin :tmp_restart
