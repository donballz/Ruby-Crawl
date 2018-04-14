require 'net/http'
require 'uri'
require 'yaml'
require 'rubygems'
require 'mechanize'

PATH = '/Users/donald/Dropbox/AO Thread Crawl/Ruby Port/'

def write(obj, fname)
	# writes any object to supplied filename. naming conflict with rT class func
	File.open(PATH + "#{fname}.yml", 'w') { |f| f.write obj.to_yaml }
end

def read(fname)
	# reads yaml file to object
	return YAML.load_file(PATH + "#{fname}.yml")
end

def get_page(url)
	# fetches webpage as flat string
	return Net::HTTP.get(URI.parse(url))
end

def annual_hash
	# return hash of blank hashes by year
	mh = {}
	(2001..2016).to_a.each { |y| mh[y] = Hash.new(0) }
	return mh
end

def login
	# login to AO and return agent
	agent = Mechanize.new
	page = agent.get('http://www.actuarialoutpost.com/actuarial_discussion_forum/index.php')
	login = page.form_with(:action => "login.php?do=login")
	login.vb_login_username = 'ADoggieDetective'
	login.vb_login_password = 'H2A5cVQzT28wCLx#'
	agent.submit(login, login.buttons.first)
	return agent
end