require_relative 'readThread.rb'
require_relative 'StringFind.rb'
require_relative 'common_funcs.rb'

def posts_per_year(fnum)
	# returns hash of posts by year for given subforum
	tcat = read("thread_cat_#{fnum}")
	tcat.each do |k, v|
		if v > 0
			mt = read("Threads/#{k}")
			mt.each { |post| puts post.pTime }
			break
		end
	end
end

posts_per_year(23)