require 'net/http'
require 'uri'
require 'yaml'

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