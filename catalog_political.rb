require_relative 'readThread.rb'
require_relative 'StringFind.rb'

STICKY = 280594

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

def get_page(url)
	# fetches webpage as flat string
	return Net::HTTP.get(URI.parse(url))
end

def build_url(fNum, pageNum)
	# pares a subforum number and page into thread list url
	server = "http://www.actuarialoutpost.com/"
	tbase = "actuarial_discussion_forum/forumdisplay.php?f="
	url = server + tbase + fNum.to_s
	url = url + "&order=desc&page=" + pageNum.to_s
	return url
end

def get_last_post(thread)
	# returns last post of given thread
	server = "http://www.actuarialoutpost.com/"
	tbase = "actuarial_discussion_forum/showthread.php?t="
	url = server + tbase + "#{thread}&page=999999"
	page = get_page(url)
	found = page.find('title="First Page - Results 1 to 10 of ')
	last = page.index('"', found)
	return page[found...last].to_i unless found == -1
	return 0
end

def get_thread_list(fnum)
	# function crawls given subforum and returns array of threads
	tlist = []
	thread, pnum, found = STICKY, 1, 0
	page = get_page(build_url(fnum, pnum))
	until tlist.include?(thread)
		# puts in list unless already on list. also ignores the sticky
		tlist.push(thread) unless thread == STICKY
		found = page.find('<td class="alt1" id="td_threadtitle_', found)
		end_tnum = page.index('"', found)
		if found == -1
			# get next page, report the page num, and save results to prevent error loss
			pnum += 1
			page = get_page(build_url(fnum, pnum)) 
			found = 0
			puts pnum
			#write(tlist, "thread_list_#{fnum}")
			thread = STICKY
			break if pnum == 5
		else
			thread = page[found...end_tnum].to_i
		end
	end
	return tlist
end

def get_all_threads(fnum)
	# function reads thread list, parses each thread and writes it to yaml
	#   keeps running hash of thread stats in case it errors out.
	tlist = read("thread_list_#{fnum}")
	tlist.each do |thread|
		tcat = read("thread_cat_#{fnum}")
		unless tcat.has_key?(thread) and tcat[thread] >= get_last_post(thread)
			parsed = MyThread.new(thread)
			parsed.write
			tcat[thread] = parsed.tPosts.length
			write(tcat, "thread_cat_#{fnum}")
			puts thread, parsed.tPosts.length
		end
	end
	return nil
end
	
#write(get_thread_list(23), 'thread_list_23')
get_all_threads(23)