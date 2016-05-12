require_relative 'readThread.rb'
require_relative 'StringFind.rb'

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
	
end
	
puts get_page(build_url(23, 2))