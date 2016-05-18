require_relative 'readThread.rb'
require_relative 'StringFind.rb'
require_relative 'common_funcs.rb'

def posts_per_year(fnum)
	# returns hash of posts by year for given subforum
	tcat = read("thread_cat_#{fnum}")
	ppy = Hash.new(0)
	tcat.each do |k, v|
		if v > 0
			mt = read("Threads/#{k}")
			mt.each { |post| ppy[post.pYear] += 1 }
		end
	end
	return ppy
end

def threads_per_year(fnum)
	# returns hash of threads per year for given subforum
	tcat = read("thread_cat_#{fnum}")
	tpy = Hash.new(0)
	tcat.each do |k, v|
		if v > 0
			mt = read("Threads/#{k}")
			tpy[mt.tYear] += 1
		end
	end
	return tpy
end

def ttesting(thread)
	mt = read("Threads/#{thread}")
	puts mt.curDate
	mt.each { |post| puts post.pTime }
end

now = Time.now
#puts posts_per_year(23)
puts threads_per_year(23)
#ttesting(308671)
puts "Run time: #{Time.now - now}"