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

MAIL_DINNER_BODY_TEMPLATE = %q[
<h3> ארוחת הערב - %s - הגיעה!</h3>
<p> %s </p>
]

MAIL_FOOTER = %q[
<br /> <br />________________________________<br />
Announcement sent using <a href="%s">Foodie</a>
] % ENV["FOODIE_URL"]
MAIL_DEFAULT_COMMENT = 'בתיאבון...'

get '/' do
  @is_dinner_time = Time.now > Time.parse(ENV["DINNER_TIME"])
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
  rest = GiveByte.get_rests[rest_id]
  rest_name = rest["name"]
  subject = MAIL_SUBJECT_TEMPLATE % rest_name
  is_dinner = rest["is_dinner"]
  body_template = is_dinner ? MAIL_DINNER_BODY_TEMPLATE : MAIL_BODY_TEMPLATE
  body = body_template % [rest_name, comments]
  body << MAIL_FOOTER

  Pony.mail({
    html_body: body,
    subject: subject
  }.merge(MAIL_OPTIONS))

  GiveByte.set_announced(rest_id)
  true
end
