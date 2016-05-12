require_relative 'readThread.rb'
require_relative 'StringFind.rb'

STICKY = 280594

def write(obj, fname)
	path = '/Users/donald/Dropbox/AO Thread Crawl/Ruby Port/'
	File.open(path + "#{fname}.yml", 'w') { |f| f.write obj.to_yaml }
end

def get_page(url)
	return Net::HTTP.get(URI.parse(url))
end

def build_url(fNum, pageNum)
	server = "http://www.actuarialoutpost.com/"
	tbase = "actuarial_discussion_forum/forumdisplay.php?f="
	url = server + tbase + fNum.to_s
	url = url + "&order=desc&page=" + pageNum.to_s
	return url
end

def get_thread_list(fnum)
	# function crawls given subforum and returns array of threads
	tlist = []
	thread, pnum, found = STICKY, 1, 0
	page = get_page(build_url(fnum, pnum))
	until tlist.include?(thread)
		# puts in list unless already on list. also ignores the sticky
		tlist.push(thread) unless thread == STICKY
		page = get_page(build_url(fnum, pnum)) if found == -1
		found = page.find('<td class="alt1" id="td_threadtitle_', found)
		end_tnum = page.index('"', found)
		if found == -1
			pnum += 1
			thread = STICKY
		else
			thread = page[found...end_tnum].to_i
		end
	end
	return tlist
end
	
write(get_thread_list(23), 'thread_list')