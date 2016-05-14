require 'net/http'
require 'uri'
require 'yaml'
require 'cgi'

def build_url(tnum, pageNum)
	server = "http://www.actuarialoutpost.com/"
	tbase = "actuarial_discussion_forum/showthread.php?t="
	url = server + tbase + tnum.to_s
	url = url + "&pp=40&page=" + pageNum.to_s
	return url
end

def get_page(url)
	return Net::HTTP.get(URI.parse(url))
end
	
def dump(tnum)
	url = build_url(tnum, 1)
	return get_page(url)		
end

puts dump(295916).type