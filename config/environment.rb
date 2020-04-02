require 'bundler'
Bundler.require
db_config = YAML.load_file('config/database.yml')
ActiveRecord::Base.establish_connection(db_config[ENV['RACK_ENV']])
