require_relative 'catalog_political.rb'

def get_next(tlist)
	tlist.each do |t|
		if t == 296892
			tnext =  tlist[tlist.index(t) + 1]
			puts tnext
			puts tlist.index(tnext)
		end
	end
end

tlist = read('thread_list_23')
get_next(tlist)
#puts tlist.length
#tlist.delete(306317)
#puts tlist.length
#write(tlist, 'thread_list_23')