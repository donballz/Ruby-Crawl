require_relative 'readThread.rb'
require_relative 'StringFind.rb'
require_relative 'common_funcs.rb'

def posts_per_year(fnum)
	# returns hash of posts by year for given subforum
	tcat = read("thread_cat_#{fnum}")
	tcat.each do |k, v|
		if v > 0
			ppy = Hash.new(0)
			mt = read("Threads/#{k}")
			puts mt.tTitle
			mt.each { |post| puts mt.tPosts.index(post) + 1 if post.pYear == 1779 }
			break
		end
	end
end

def ttesting(thread)
	mt = read("Threads/#{thread}")
	puts mt.curDate
	mt.each { |post| puts post.pTime }
end

#posts_per_year(23)
#ttesting(308671)