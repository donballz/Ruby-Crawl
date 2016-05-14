require 'yaml'

def write(obj, fname)
	# writes any object to supplied filename. naming conflict with rT class func
	path = '/Users/donald/Dropbox/AO Thread Crawl/Ruby Port/'
	File.open(path + "#{fname}.yml", 'w') { |f| f.write obj.to_yaml }
end

empty = {}

write(empty, 'thread_cat_23')