require_relative 'readThread.rb'
require_relative 'threadDict.rb'

STICKY = [280594, 310192]

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

def get_gap_threads(fnum)
	# function reads thread catalog and gets any files found to be missing
	puts 'retreiving parse history...'
	phist = read("parse_history_#{fnum}")
	puts 'retrieving thread catalog...'
	tcat = read("thread_cat_#{fnum}")
	time = Time.now
	ok, lost = 0, 0
	tcat.each do |k ,v|
		if not File.exist?("#{PATH}/Threads/#{k}.yml")
			puts "parsing missing thread #{k}..."
			parsed = MyThread.new(k)
			parsed.write
			tcat[k] = parsed.tPosts.length
			phist.update(k, parsed.tPosts.length, time)
			puts "#{k}, #{tcat[k]} posts corrected"
			lost += 1
		else
			ok += 1
		end
	end
	puts 'writing parse history...'
	phist.write
	puts 'writing thread catalog...'
	write(tcat, "thread_cat_#{fnum}")
	puts "#{ok} threads were ok"
	puts "#{lost} lost threads were found"
	return time
end
	
#write(get_thread_list(23), 'thread_list_23')
#write(update_tlist(23), 'tllist_update_23')
time = Time.now
#tlist, replies = update_tlist(23, 41)
loaded = get_gap_threads(23)
puts "Time to load #{loaded - time}"
puts "Time to parse #{Time.now - time}"
puts loaded # Saved time stamp
#test_tf_stat
