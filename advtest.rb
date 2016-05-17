#require_relative 'catalog_political.rb'
require 'yaml'

def write(obj, fname)
	# writes any object to supplied filename. naming conflict with rT class func
	path = '/Users/donald/Dropbox/AO Thread Crawl/Ruby Port/'
	File.open(path + "#{fname}.yml", 'w') { |f| f.write obj.to_yaml }
end

def read(fname)
	# reads yaml file to object
	path = '/Users/donald/Dropbox/AO Thread Crawl/Ruby Port/'
	return YAML.load_file(path + "#{fname}.yml")
end

def get_next(tlist, tnum)
	tlist.each do |t|
		if t == tnum
			tnext =  tlist[tlist.index(t) + 1]
			puts tnext
			puts tlist.index(tnext)
		end
	end
end

def remove_thread(tlist, tnum)
	puts tlist.length
	tlist.delete(tnum)
	puts tlist.length
	write(tlist, 'thread_list_23')
end

tlist = read('thread_list_23')
get_next(tlist, 9145)
#remove_thread(tlist, 255841)
#puts tlist.length
