require 'sinatra'
require 'json'

require_relative 'givebyte'
get '/' do
  @rests = GiveByte.get_rests
  puts @rests
  erb :index
end

get '/foodie.js' do
  coffee :foodie
end
