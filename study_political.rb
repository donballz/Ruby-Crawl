require_relative 'readThread.rb'
require_relative 'readThreadExtend.rb'
require_relative 'threadDict.rb'
require_relative 'StringFind.rb'
require_relative 'common_funcs.rb'

FORUM = 23

def per_year_stats(fnum)
	# returns hashes by year for given subforum
	tcat = read("thread_cat_#{fnum}")
	ppy = Hash.new(0)
	tpy = Hash.new(0)
	pppy = annual_hash
	ptpy = annual_hash
	pqpy = annual_hash
	pwpy = annual_hash
	uppt = Hash.new(0)
	tcat.each do |k, v|
		if v > 0
			mt = read("Threads/#{k}")
			tpy[mt.tPosts[0].pYear] += 1
			unique_posters = []
			mt.each do |post| 
				ppy[post.pYear] += 1 
				pppy[post.pYear][post.pPoster] += 1
				ptpy[post.pYear]["#{mt.tNum}: #{mt.tTitle}"] += 1
				post.pQuoted.each { |q, qnum| pqpy[post.pYear][q] += 1 }
				words = post.pPost.downcase.tr('.,;[]{}!@#$%^&*()<>?:"\|/`~', '').split
				words.each { |w| pwpy[post.pYear][w] += 1 }
				unless unique_posters.include?(post.pPoster)
					uppt[mt.tNum] += 1
					unique_posters.push(post.pPoster)
				end
			end
		end
	end
	return tpy, ppy, pppy, ptpy, pqpy, pwpy, uppt
end

def ttesting(thread)
	mt = read("Threads/#{thread}")
	uppt = Hash.new(0)
	unique_posters = []
	mt.each do |post| 
		unless unique_posters.include?(post.pPoster)
			uppt[mt.tNum] += 1
			unique_posters.push(post.pPoster)
		end
	end
	return uppt
end

def run_stats(fnum)
	tpy, ppy, pppy, ptpy, pqpy, pwpy, uppt = per_year_stats(fnum)
	write(tpy, 'threads_per_year')
	write(ppy, 'posts_per_year')
	write(pppy, 'per_poster_per_year')
	write(ptpy, 'per_thread_per_year')
	write(pqpy, 'per_quoted_per_year')
	write(pwpy, 'per_word_per_year')
	write(uppt, 'unique_posters_per_thread')
end

def simple_print(mh)
	# prints naive hash by year
	mh.each { |y, v| puts "#{y} #{v}" }
	return nil
end

def complex_print(mh, limit)
	# prints more complex annual hash
	mh.each do |y, subhash|
		subhash.each { |k, v| puts "#{y} #{k} #{v}" if v > limit}
	end
end

def obsessed(fnum)
	# comparative stats for TAA and erose
	tcat = read("thread_cat_#{fnum}")
	erose = ['erosewater', "Rex Ryan's pet coyote"]
	ero_m = ['erosewater', "rex ryan's pet coyote", 'rrpc', 'erose']
	taa = ['TheActuarialAssistant']
	taa_m = ['theactuarialassistant', 'taa']
	mh = annual_hash
	tcat.each do |k, v|
		if v > 0
			mt = read("Threads/#{k}")
			mt.each do |post|
				tq, eq = 0, 0 # track if either quotes the other
				words = post.pPost.downcase.tr('.,;[]{}!@#$%^&*()<>?:"\|/`~', '').split
				if taa.include?(post.pPoster) 
					mh[post.pYear]['TAA'] += 1
					tq = 1 if post.pQuoted.keys.any? { |q| erose.include? q }
					mh[post.pYear]['TAQ'] += tq
					mh[post.pYear]['TAM'] += 1 - tq if words.any? { |w| ero_m.include? w }
				elsif erose.include?(post.pPoster)
					mh[post.pYear]['ERS'] += 1
					eq = 1 if post.pQuoted.keys.any? { |q| taa.include? q }
					mh[post.pYear]['ERQ'] += eq
					mh[post.pYear]['ERM'] += 1 - eq if words.any? { |w| taa_m.include? w }
				end
			end
		end
	end
	return mh
end

def find_all(fnum, poster, phrase, skip=0)
	# finds all instances of a poster and post phrase unless skip is set to 1, then only finds first
	tcat = read("thread_cat_#{fnum}")
	mh = annual_hash
	found = 0
	tcat.each do |k, v|
		if v > 0
			mt = read("Threads/#{k}")
			mt.each do |post|
				if post.pPoster == poster and post.pPost.downcase.find(phrase) != -1
					puts "thread: #{k}, post: #{post.pNum}"
					found = 1
					break if skip == 1
				end
			end
		end
		break if skip == 1 and found == 1
	end
end

def ppd_all(fnum, poster)
	# returns posts per day for given poster and forum
	ppd = Hash.new(0)
	tcat = read("thread_cat_#{fnum}")
	tcat.each do |k, v|
		if v > 0
			mt = read("Threads/#{k}")
			ppd = ppd + mt.posts_per_day(poster)
		end
	end
	return ppd
end

def all_posts_by(fnum, poster)
	# prints all of a poster's posts in a given forum
	tcat = read("thread_cat_#{fnum}")
	tcat.each do |k, v|
		if v > 0
			mt = read("Threads/#{k}")
			mt.posts_by(poster)
		end
	end
end

now = Time.now
#run_stats(FORUM)
#mh = read('unique_posters_per_thread')
#complex_print(mh, 1) # set to 1 for words, else 0
#simple_print(mh)
#puts ttesting(308604)
#simple_print(obsessed(FORUM))
#find_all(FORUM, 'Childish Gambino', 'word of the day', 1)
#mtd = ThreadDict.new(FORUM)
#mtd.write
#find_all(FORUM, 'jas66Kent', 'coon')
#ppd_all(23, 'Childish Gambino').myPrint
#all_posts_by(FORUM, "Ito's Phlegm")
stump = read('Threads/305755')
ppd = stump.posts_per_day()
ppd.myPrint
puts "Run time: #{Time.now - now}"