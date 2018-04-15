require_relative 'readThread.rb'
require_relative 'StringFind.rb'
require_relative 'threadDict.rb'
require_relative 'common_funcs.rb'

STICKY = [280594, 310192]

###############
#### TO DO ####
# 2. Update the thread dict after parse
# 3. Combine the parse history and thread dict classes to save i/o
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
	url = FORUM + '/forumdisplay.php?f=' + fNum.to_s
	url = url + "&order=desc&page=" + pageNum.to_s
	return url
end

def get_thread_list(fnum)
	# function crawls given subforum and returns array of ALL threads
	# needs mechanize update
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

def update_tlist(fnum, num)
	# function crawls given subforum and returns array of threads (num pages)
	tlist, replies = [], []
	(1..num).to_a.each do |pnum|
		pol = AGENT.get(build_url(fnum, pnum))
		pol.links.each do |l|
			uriStr = l.uri.to_s 
			begl = uriStr.find('misc.php?do=whoposted&t=')
			if begl != -1
				t = uriStr[begl, 99].to_i
				unless tlist.include?(t) or STICKY.include?(t)
					tlist.push(t)
					replies.push(l.text.delete(',').to_i + 1)
				end
			end
		end
	end
	return tlist, replies
end

def get_all_threads(fnum, tlist, replies, start)
	# function reads thread list, parses each thread and writes it to yaml
	#   keeps running hash of thread stats in case it errors out.
	#tlist = read("tllist_update_#{fnum}")
	puts 'retreiving parse history...'
	phist = read("parse_history_#{fnum}")
	#tdict = read("thread_dict_#{fnum}")
	puts 'retrieving thread catalog...'
	tcat = read("thread_cat_#{fnum}")
	time = Time.now
	tlist.slice(start, tlist.length).each do |tnum|
		unless tcat.has_key?(tnum) and tcat[tnum] >= replies[tlist.find_index(tnum)]
			if tcat.has_key?(tnum)
				puts "parsing existing thread #{tnum}..."
				parsed = read("Threads/#{tnum}")
				parsed.add_to_thread
				status = "#{parsed.tPosts.length - tcat[tnum]} added"
			else
				puts "parsing new thread #{tnum}..."
				parsed = MyThread.new(tnum)
				status = 'created'
			end
			parsed.write
			tcat[tnum] = parsed.tPosts.length
			phist.update(tnum, parsed.tPosts.length, time)
			#tdict.update(parsed)
			puts "#{tnum}, #{tcat[tnum]} posts #{status}"
		else
			puts "#{tnum}, #{tcat[tnum]} no change"
		end
	end
	puts 'writing parse history...'
	phist.write
	#tdict.write
	puts 'writing thread catalog...'
	write(tcat, "thread_cat_#{fnum}")
	return time
end

def tfile_status(tlist, tcat)
	# sets status indictors for each thread in tlist
	#   0 = 0 posts
	#   1 = file good
	#   2 = file missing
	tcat_new = {}
	tlist.each do |t| 
		if tcat.has_key?(t)
			if not File.exist?("#{PATH}/Threads/#{t}.yml")
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
#write(update_tlist(23), 'tllist_update_23')
time = Time.now
tlist, replies = update_tlist(23, 4)
loaded = get_all_threads(23, tlist, replies, 0)
puts "Time to load #{loaded - time}"
puts "Time to parse #{Time.now - time}"
#test_tf_stat
