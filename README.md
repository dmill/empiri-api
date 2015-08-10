Empiri-API
===========

Dependencies
------------
- Ruby 2.2.2
- Bundler
- PostgreSQL

Setup
------------
Create a database.yml with the necessary information and credentials to connect to your postgres database. Then run:
    bundle install
    bundle exec rake db:setup

Running The App
---------------
   bundle exec puma
