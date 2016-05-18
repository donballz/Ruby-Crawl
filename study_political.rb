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
	# returns hashes by year for given subforum
	tcat = read("thread_cat_#{fnum}")
	ppy = Hash.new(0)
	tpy = Hash.new(0)
	pppy = annual_hash
	ptpy = annual_hash
	pqpy = annual_hash
	pwpy = annual_hash
	tcat.each do |k, v|
		if v > 0
			mt = read("Threads/#{k}")
			tpy[mt.tPosts[0].pYear] += 1
			mt.each do |post| 
				ppy[post.pYear] += 1 
				pppy[post.pYear][post.pPoster] += 1
				ptpy[post.pYear]["#{mt.tNum}: #{mt.tTitle}"] += 1
				post.pQuoted.each { |q, qnum| pqpy[post.pYear][q] += 1 }
				words = post.pPost.downcase.tr('.,;[]{}!@#$%^&*()<>?:"\|/`~', '').split
				words.each { |w| pwpy[post.pYear][w] += 1 }
			end
		end
	end
	return tpy, ppy, pppy, ptpy, pqpy, pwpy
end

def ttesting(thread)
	mt = read("Threads/#{thread}")
	puts mt.curDate
	mt.each { |post| puts post.pTime }
end

now = Time.now
#puts posts_per_year(23)
tpy, ppy, pppy, ptpy, pqpy, pwpy = per_year_stats(23)
puts pppy
puts ptpy
puts pqpy
puts pwpy
write(tpy, 'threads_per_year')
write(ppy, 'posts_per_year')
write(pppy, 'per_poster_per_year')
write(ptpy, 'per_thread_per_year')
write(pqpy, 'per_quoted_per_year')
write(pwpy, 'per_word_per_year')
#ttesting(308671)
puts "Run time: #{Time.now - now}"