require_relative 'readThreadExtend.rb'
require_relative 'StringFind.rb'

STICKY = [280594, 310192]
testT = MyThread.new(331538)
#testT = read(331451)
testT.print_thread
#page = get_page(login, testT.tUrl)

def find_all(page, loc)
	pos = -1
	pall = []
	until pos == nil
		pos = page.index(loc, pos + 1)
		pall.push(pos) if pos != nil
	end
	return pall
end

#puts 'pm', find_all(page, 'post_message_')
#puts 'me', find_all(page, '<!-- / message -->')
#puts 'bu', find_all(page, '<a class="bigusername"')
#puts 'et', find_all(page, '<td class="thead">')

def find_head
	pos = 0
	edl = -1
	until pos == nil
		pos = page.index('<td class="thead">', edl + 1)
		edl = page.index('</td>', pos + 1)
		puts page[pos...edl+5]
	end
end

def get_last_post(tnum)
	# returns last post of given thread
	url = FORUM + '/showthread.php?t=' + "#{tnum}&page=999999"
	#puts url
	page = get_page(url)
	puts page
	found = page.find('title="First Page - Results 1 to 40 of ')
	#puts found
	last = page.index('"', found)
	#puts last
	return page[found...last].tr(',','').to_i unless found == -1
	return 0
end

def build_url(fNum, pageNum)
	# pares a subforum number and page into thread list url
	url = FORUM + '/forumdisplay.php?f=' + fNum.to_s
	url = url + "&order=desc&page=" + pageNum.to_s
	return url
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
					replies.push(l.text.delete(',').to_i)
				end
			end
		end
	end
	return tlist, replies
end

#puts get_last_post(testT.tNum)

def test_whopost
	#puts pol.links_with(:search => 'whoposted')
	pol.links.each do |l| 
		if l.uri != nil and l.uri.to_s.index("whoposted") != nil
			puts l.uri 
			puts l.text
		end
	end
end

#pol = AGENT.get(build_url(23, 30))
#tlist, replies = update_tlist(23, 1)
#(0...tlist.length).to_a.each { |i| puts "thread: #{tlist[i]} replies; #{replies[i]}" }