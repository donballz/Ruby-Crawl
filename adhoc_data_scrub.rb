require_relative 'readThread.rb'
require_relative 'StringFind.rb'
require_relative 'common_funcs.rb'

def fix_bad_yesterdays(fnum)
	# iterates over all the political thread files and repulls thread.
	# can't trust it to one day before curDate because curDate updates on add.
	tcat = read("thread_cat_#{fnum}")
	tcat.each do |k, v|
		if v > 0
			mt = read("Threads/#{k}")
			repull = false
			mt.each do |post| 
				if post.pYear == 1779 
					repull = true
					break
				end
			end
			if repull
				nt = MyThread.new(k)
				nt.write
				tcat[k] = nt.tPosts.length
				puts "#{k} repulled"
			end
		end
	end
	write(tcat, "thread_cat_#{fnum}")
	return nil
end

def update_tcat(fnum)
	subset = [308568 ,308494 ,305755 ,236416 ,256694 ,305864 ,308522 ,308470 ,270316 ,308498 ,308541 ,307384 ,293660 ,307538 ,308620 ,308601 ,308671 ,308664 ,308604]
	tcat = read("thread_cat_#{fnum}")
	tcat.each do |k, v|
		if subset.include?(k)
			mt = read("Threads/#{k}")
			tcat[k] = mt.tPosts.length
		end
	end
	write(tcat, "thread_cat_#{fnum}")
	return nil
end

#fix_bad_yesterdays(23)
update_tcat(23)