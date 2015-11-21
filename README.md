# EmpiriApi

Development Setup
-----------------

*First download and set up dependencies:*
  - postgresql
  - erlang
  - elixir
  - phoenix

Install mix dependencies:

    $ mix deps.get

Set up database config files:

    # dev.exs
    # test.exs
    # prod.exs

Create and migrate the database:

    $ mix ecto.create
    $ mix ecto.migrate

Create and migrate the test database:

    $ env MIX_ENV=test mix ecto.create
    $ env MIX_ENV=test mix ecto.migrate

Run the application:

    $ PORT=4000 mix phoenix.server

Run an interactive console:

    $ PORT=4001 iex -S mix phoenix.server

Run the tests:

    $ mix test
