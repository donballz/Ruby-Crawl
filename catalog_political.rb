require_relative 'readThread.rb'
require_relative 'StringFind.rb'

STICKY = 280594
PATH = '/Users/donald/Dropbox/AO Thread Crawl/Ruby Port/'

###############
#### TO DO ####
# 1. Modify get_all_threads to add new posts instead of rebuilding thread each time
###############

class MyThread
	# extend class to allow partial builds
	def add_to_thread()
		# cuts off post-array at last full page and then starts over at new posts
		full = @tPosts.length - @tPosts.length % 40
		@tPosts.slice!(full, @tPosts.length)
		@tPostLog.slice!(full, @tPostLog.length)
		build_thread(full / 40 + 1)
	end
end

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
		else
			thread = page[found...end_tnum].to_i
		end
	end
	return tlist
end

def update_tlist(fnum)
	# function crawls given subforum and returns array of threads
	tlist = []
	thread = STICKY
	page = get_page(build_url(fnum, 1))
	(1..5).to_a.each do |pnum|
		found = 0
		until found == -1
			found = page.find('<td class="alt1" id="td_threadtitle_', found)
			end_tnum = page.index('"', found)
			if found == -1
				# get next page, report the page num, and save results to prevent error loss
				page = get_page(build_url(fnum, pnum)) 
				puts pnum
				thread = STICKY
			else
				thread = page[found...end_tnum].to_i
			end
			tlist.push(thread) unless thread == STICKY
		end
	end
	return tlist
end

def get_all_threads(fnum, start)
	# function reads thread list, parses each thread and writes it to yaml
	#   keeps running hash of thread stats in case it errors out.
	tlist = read("thread_list_#{fnum}")
	tlist.slice(start, tlist.length).each do |thread|
		tcat = read("thread_cat_#{fnum}")
		unless tcat.has_key?(thread) and tcat[thread] >= get_last_post(thread)
			if tcat.has_key?(thread)
				parsed = read("Threads/#{thread}")
				parsed.add_to_thread
				status = 'added'
			else
				parsed = MyThread.new(thread)
				status = 'created'
			end
			parsed.write
			tcat[thread] = parsed.tPosts.length
			write(tcat, "thread_cat_#{fnum}")
			puts "#{thread}, #{tcat[thread]} #{status}"
		else
			puts "#{thread}, #{tcat[thread]} cleared"
		end
	end
	return nil
end

def tfile_status(tlist, tcat)
	# sets status indictors for each thread in tlist
	#   0 = 0 posts
	#   1 = file good
	#   2 = file missing
	tcat_new = {}
	tlist.each do |t| 
		if tcat.has_key?(t)
			if not File.exist?("#{PATH}Threads/#{t}.rb")
				tcat_new[t] = [t, 2]
			elsif tcat[t] == 0
				tcat_new[t] = [t, 0]
			else
				tcat_new[t] = [t, 1]
			end
		end
	end
	return tcat_new
end

def test_tf_stat()
	# testing for tfile_status
	tcat = read('thread_cat_23')
	tlist = read('thread_list_23')
	tlist.slice!(0, 50)
	puts tlist.length
	puts tfile_status(tlist, tcat.delete_if { |k,v| tlist.include?(k) } )
end
	
#write(get_thread_list(23), 'thread_list_23')
#puts write(update_tlist(23), 'tllist_update_23')
#get_all_threads(23, 37374)
test_tf_stat
