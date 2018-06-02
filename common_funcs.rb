require 'yaml'
require 'mysql2'
require 'rubygems'
require 'mechanize'
require_relative 'StringFind.rb'

PATH = '/Users/donald/Dropbox/AO Thread Crawl/Ruby Port'
FORUM = 'http://www.actuarialoutpost.com/actuarial_discussion_forum'
SRVR = 'Donalds-Mini.hsd1.in.comcast.net'
USER = 'ruby'
PSWD = "22C393363C228C783C5BDB15057AE288"
SCMA = 'aopol'

def write(obj, fname)
	# writes any object to supplied filename. naming conflict with rT class func
	File.open(PATH + "/#{fname}.yml", 'w') { |f| f.write obj.to_yaml }
end

def read(fname)
	# reads yaml file to object
	return YAML.load_file(PATH + "/#{fname}.yml")
end

def annual_hash
	# return hash of blank hashes by year
	mh = {}
	(2001..2016).to_a.each { |y| mh[y] = Hash.new(0) }
	return mh
end

def sql_qry(fname, con)
	# runs single sql query saved in a .sql file
	qry = File.read("#{PATH}/#{fname}.sql")
	return con.query(qry)
end

def login
	# login to AO and return agent
	key = File.read("#{PATH}/key.txt")
	pwd = "3A83705F2E72B334CD996837D873A200C0A45F531EAB8200"
	agent = Mechanize.new
	page = agent.get("#{FORUM}/index.php")
	login = page.form_with(:action => 'login.php?do=login')
	login.vb_login_username = 'ADoggieDetective'
	login.vb_login_password = pwd.decrypt(key)
	agent.submit(login, login.buttons.first)
	return agent
end

AGENT = login

def get_page(url)
	# fetches webpage as flat string
	return AGENT.get(url).parser.xpath('//table').to_html
end