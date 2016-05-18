require_relative 'readThread.rb'
require_relative 'StringFind.rb'
require_relative 'common_funcs.rb'

def annual_hash
	# return hash of blank hashes by year
	mh = {}
	(2001..2016).to_a.each { |y| mh[y] = Hash.new(0) }
	return mh
end

def per_year_stats(fnum)
	# returns hash of posts by year for given subforum
	tcat = read("thread_cat_#{fnum}")
	ppy = Hash.new(0)
	tpy = Hash.new(0)
	top_posters = annual_hash
	tcat.each do |k, v|
		if v > 0
			mt = read("Threads/#{k}")
			tpy[mt.tPosts[0].pYear] += 1
			mt.each do |post| 
				ppy[post.pYear] += 1 
				top_posters[post.pYear][post.pPoster] += 1
			end
		end
	end
	return tpy, ppy
end

def ttesting(thread)
	mt = read("Threads/#{thread}")
	puts mt.curDate
	mt.each { |post| puts post.pTime }
end

now = Time.now
#puts posts_per_year(23)
tpy, ppy, tp = per_year_stats(23)
puts tpy
puts ppy
puts tp
#ttesting(308671)
puts "Run time: #{Time.now - now}"