require_relative 'forum_crawl.rb'

STICKY = [15859]

fnum = 22
	
time = Time.now
#write(get_thread_list(fnum), "thread_list_#{fnum}")
#write(update_tlist(fnum), "tllist_update_#{fnum}")
tlist, replies = update_tlist(fnum, 10)
loaded = get_all_threads(fnum, tlist, replies, 0)
puts "Time to load #{loaded - time}"
puts "Time to parse #{Time.now - time}"
puts loaded # Saved time stamp
#test_tf_stat
