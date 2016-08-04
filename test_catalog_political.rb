require_relative 'StringFind.rb'
require_relative 'catalog_political.rb'

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

tlist = update_tlist(23)
puts tlist.length