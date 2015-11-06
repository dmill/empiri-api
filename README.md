# EmpiriApi

Development Setup
-----------------

- Download and set up postgresql, elixir, erlang, and phoenix
- Set up database permissions. From psql:
    # CREATE user empiri;
    # ALTER USER empiri CREATEDB;
- Create and migrate the database:
    $ mix ecto.create
    $ mix ecto.migrate
- Create and migrate the test database:
    $ env MIX_ENV=test mix ecto.create
    $ env MIX_ENV=test mix ecto.migrate
- Run the application:
    $ mix phoenix.server
- Run an interactive console:
    $ iex -S mix phoenix.server
-Run the tests:
    $ mix test




