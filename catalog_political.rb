require_relative 'readThread.rb'
require_relative 'StringFind.rb'
require_relative 'common_funcs.rb'

STICKY = [280594, 310192]

###############
#### TO DO ####
# 1. 
###############

class MyThread
	# extend class to allow partial builds
	def add_to_thread()
		# cuts off post-array at last full page and then starts over at new posts
		full = @tPosts.length - @tPosts.length % 40
		@tPosts.slice!(full, @tPosts.length)
		@tPostLog.slice!(full, @tPostLog.length)
		build_thread(full / 40 + 1)
		@curDate = DateTime.now
	end
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
	return page[found...last].tr(',','').to_i unless found == -1
	return 0
end

def get_thread_list(fnum)
	# function crawls given subforum and returns array of threads
	tlist = []
	thread, pnum, found = STICKY[0], 1, 0
	page = get_page(build_url(fnum, pnum))
	until tlist.include?(thread)
		# puts in list unless already on list. also ignores the sticky
		tlist.push(thread) unless STICKY.include?(thread)
		found = page.find('<td class="alt1" id="td_threadtitle_', found)
		end_tnum = page.index('"', found)
		if found == -1
			# get next page, report the page num, and save results to prevent error loss
			pnum += 1
			page = get_page(build_url(fnum, pnum)) 
			found = 0
			puts pnum
			#write(tlist, "thread_list_#{fnum}")
			thread = STICKY[0]
		else
			thread = page[found...end_tnum].to_i
		end
	end
	return tlist
end

def update_tlist(fnum)
	# function crawls given subforum and returns array of threads
	tlist = []
	thread = STICKY[0]
	page = get_page(build_url(fnum, 1))
	(2..10).to_a.each do |pnum|
		found = 0
		until found == -1
			found = page.find('<td class="alt1" id="td_threadtitle_', found)
			end_tnum = page.index('"', found)
			if found == -1
				# get next page, report the page num, and save results to prevent error loss
				page = get_page(build_url(fnum, pnum)) 
				puts pnum
				thread = STICKY[0]
			else
				thread = page[found...end_tnum].to_i
			end
			tlist.push(thread) unless STICKY.include?(thread)
		end
	end
	return tlist
end

def get_all_threads(fnum, start)
	# function reads thread list, parses each thread and writes it to yaml
	#   keeps running hash of thread stats in case it errors out.
	tlist = read("tllist_update_#{fnum}")
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
			if not File.exist?("#{PATH}Threads/#{t}.yml")
				tcat_new[t] = [tcat[t], 2]
			elsif tcat[t] == 0
				tcat_new[t] = [tcat[t], 0]
			else
				tcat_new[t] = [tcat[t], 1]
			end
		end
	end
	return tcat_new
end

def test_tf_stat()
	# testing for tfile_status
	tcat = read('thread_cat_23')
	tlist = read('thread_list_23')
	status = tfile_status(tlist, tcat)
	hist = Hash.new(0)
	status.each { |k, v| hist[v[1]] += 1 }
	#puts status.keep_if { |k,v| v[1] == 2 }
	#puts tcat.keep_if { |k,v| [305755, 305483, 306133, 290400].include?(k) }
	puts hist
end
	
#write(get_thread_list(23), 'thread_list_23')
write(update_tlist(23), 'tllist_update_23')
get_all_threads(23, 0)
puts Time.now
#test_tf_stat
