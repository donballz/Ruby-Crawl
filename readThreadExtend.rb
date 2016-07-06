require_relative 'readThread.rb'

def read(tnum)
	path = '/Users/donald/Dropbox/AO Thread Crawl/Ruby Port/Threads/'
	return YAML.load_file(path + "#{tnum}.yml")
end

class Hash
	def myPrint(reverse = false)
		sorted = self.sort_by { |k, v| v }
		if reverse
			sorted.reverse.each { |k, v| puts "#{k}: #{v}" }
		else
			sorted.each { |k, v| puts "#{k}: #{v}" }
		end
	end
end

class MyThread
	
	def print_thread()
		puts self.tTitle
		puts self.tOP
		self.tPosts.each { |post| puts "#{post.pNum}: #{post.pPoster}: #{post.pPost}" }
		return nil
	end

	def who_posted()
		posters = Hash.new(0)
		self.tPosts.each { |post| posters[post.pPoster] += 1 }
		posters.myPrint(true)
		return nil
	end
	
	def posts_per_day()
		days = Hash.new(0)
		self.tPosts.each { |post| days[post.pTime.split[0]] += 1 }
		days.myPrint(true)
		return nil
	end
	
	def posts_per_day(poster)
		days = Hash.new(0)
		self.tPosts.each { |post| days[post.pTime.split[0]] += 1 if post.pPoster = poster }
		days.myPrint(true)
		return nil
	end
	
	def most_quoted() 	
		posters = Hash.new(0)
		self.tPosts.each do |post| 
			post.pQuoted.each { |q, qnum| posters[q] += 1 }
		end
		posters.myPrint(true)
		return nil
	end
	
	def first_post() 
		posters = Hash.new()
		self.tPosts.each { |post| posters[post.pPoster] = post.pTime if not(posters.has_key?(post.pPoster)) }
		#posters.myPrint
		#return nil
		return posters
	end
	
	def posts_by(poster)
		self.tPosts.each do |post|
			puts "#{post.pNum}: #{post.pPost}" if post.pPoster == poster
		end
		return nil
	end
	
	def who_quoted(poster)
		posters = Hash.new(0)
		self.tPosts.each do |post|
			posters[post.pPoster] += 1 if post.pQuoted.has_key?(poster)
		end
		posters.myPrint(true)
		return nil
	end
	
	def find_word(word)
		posters = Hash.new(0)
		self.tPosts.each do |post|
			puts "#{post.pPoster}: #{post.pPost}" unless post.pPost.index(word) == nil
		end
		return nil
	end

end

def annual_hash
	# return hash of blank hashes by year
	mh = {}
	(2001..2016).to_a.each { |y| mh[y] = Hash.new(0) }
	return mh
end

def simple_print(mh)
	# prints naive hash by year
	mh.each { |y, v| puts "#{y} #{v}" }
	return nil
end

def Main()
	#blasphemy = read(306133)
	#blasphemy.first_post
	
	#m.most_quoted()
	#m.tPosts.each { |p| puts "here #{p.pQuoted}" }
	#print_thread(m)
	
	#puts m.tPosts[0].pTime[14,5]
	
	#millenial = MyThread.new(305295)		# reef thread for testing unloaded pages
	#puts 'confirmed' if millenial.tTitle == nil
	
	#bump = read(101562)
	
	#trump = read(305755)
	#trump.who_posted
	
	#veep = read(308177)
	#veep.posts_by('erosewater')
	
end

def store_threads()
	#blasphemy = MyThread.new(306133)
	#blasphemy.write
	#kasich = MyThread.new(305483)
	#kasich.write
	#vaccines = MyThread.new(290400)
	#vaccines.write
	#blitzen = MyThread.new(303374)
	#blitzen.write
	#bump = MyThread.new(101562)
	#bump.write
	#risk = MyThread.new(50)
	#risk.print_thread
	nnnnnot = MyThread.new(161498)
	nnnnnot.write
end

#now = Time.now
#Main()
#store_threads()
#puts "Run time: #{Time.now - now}"