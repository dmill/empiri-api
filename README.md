# EmpiriApi

Development Setup
-----------------

*First download and set up dependencies:*
  - postgresql
  - erlang
  - elixir
  - phoenix

Set up database permissions. From psql:

    # CREATE user empiri;
    # ALTER USER empiri CREATEDB;

Create and migrate the database:

    $ mix ecto.create
    $ mix ecto.migrate

Create and migrate the test database:

    $ env MIX_ENV=test mix ecto.create
    $ env MIX_ENV=test mix ecto.migrate

Install mix dependencies:

    $ mix deps.get

Run the application:

    $ PORT=4000 mix phoenix.server

Run an interactive console:

    $ PORT=4001 iex -S mix phoenix.server

Run the tests:

    $ mix test




