require_relative 'forum_crawl.rb'

STICKY = [15859]

fnum = 22
	
time = Time.now
#write(get_thread_list(fnum), "thread_list_#{fnum}")
#write(update_tlist(fnum), "tllist_update_#{fnum}")
#tlist, replies = update_tlist(fnum, 1000)
#write(tlist, "thread_list_#{fnum}")
#write(replies, "replies_#{fnum}")
tlist = read("thread_list_#{fnum}")
replies = read("replies_#{fnum}")
loaded = get_all_threads(fnum, tlist, replies, 0)
puts "Time to load #{loaded - time}"
puts "Time to parse #{Time.now - time}"
puts loaded # Saved time stamp
#test_tf_stat
