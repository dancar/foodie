# -*- coding: utf-8 -*-
require 'sinatra'
require 'json'
require 'pony'
require_relative 'givebyte'
require 'yaml'

YAML.load(File.read(File.expand_path('../.env', __FILE__))).each do |key, value|
  ENV[key] = value
end

MAIL_OPTIONS = {
  from: ENV['MAIL_FROM'],
  to: ENV['MAIL_TO'],
  via: :smtp,
  via_options: {
    address: 'smtp.gmail.com',
    port: '587',
    enable_starttls_auto: true,
    user_name: ENV['MAIL_UN'],
    password: ENV['MAIL_PW'],
    authentication: :plain
  }
}.freeze

MAIL_SUBJECT_TEMPLATE = %q{[Food] %s}
MAIL_BODY_TEMPLATE = %q[
<h3> המשלוח של %s הגיע. </h3>
<p> %s </p>
]
MAIL_DEFAULT_COMMENT = 'בתיאבון...'

DINNER_DATA = JSON.load(File.read(File.expand_path("../dinners.json", __FILE__))) rescue nil

get '/' do

  @rests = GiveByte.get_rests
  puts @rests
  erb :index
end

get '/foodie.js' do
  coffee :foodie
end

post '/announce' do
  comments = request['comments']
  comments = MAIL_DEFAULT_COMMENT if comments.blank?

  rest_id = request['rest_id']
  rest_name = GiveByte.get_rest_name(rest_id)

  Pony.mail({
    html_body: MAIL_BODY_TEMPLATE % [rest_name, comments],
    subject: MAIL_SUBJECT_TEMPLATE % rest_name
  }.merge(MAIL_OPTIONS))

  GiveByte.set_announced(rest_id)
  true
end
