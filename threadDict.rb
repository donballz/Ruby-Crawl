require_relative 'readThread.rb'
require_relative 'common_funcs.rb'

class ThreadDict
	# list of thread elements for faster searching
	ATTRS = [:pNums, :pPosters, :pQuoted, :pTimes, :tNums, :tTitles, 
			 :tOPs, :tNumsUnq, :tTitlesUnq, :tOPsUnq, :tTimesUnq]
	attr_reader(*ATTRS)
	
	def initialize(fnum)
		@fNum = fnum
		@pNums = []
		@pPosters = []
		@pQuoted = []
		@pTimes = []
		@tNums = []
		@tTitles = []
		@tOPs = []
		@tNumsUnq = []
		@tTitlesUnq = []
		@tOPsUnq = []
		@tTimesUnq = []
		make_lists(fnum)
	end
	
	def write
		# write yaml file of this object
		path = '/Users/donald/Dropbox/AO Thread Crawl/Ruby Port/'
		File.open(path + "thread_dict_#{@fNum}.yml", 'w') { |f| f.write self.to_yaml }
	end
	
	def make_lists(fnum)
		# the real initialize method
		tcat = read("thread_cat_#{fnum}")
		tcat.each do |k, v|
			if v > 0
				mt = read("Threads/#{k}")
				@tNumsUnq.push(k)
				@tTitlesUnq.push(mt.tTitle)
				@tOPsUnq.push(mt.tTitle)
				op = 1
				mt.each do |post|
					if op == 1
						@tTimesUnq.push(post.pTime)
						op = 0
					end
					@pNums.push(post.pNum)
					@pPosters.push(post.pPoster)
					#@pQuoted # add later
					@pTimes.push(post.pTime)
				end
			end
		end
	end
end

class ParseHistory
	# class to track parse history
	ATTRS = [:updateTimes, :threadTimes, :threadPosts]
	attr_reader(*ATTRS)
	
	def initialize(fnum, init)
		@fNum = fnum
		@updateTimes = [init]
		@threadTimes = {}
		@threadPosts = {}
		build_history(fnum, init)
	end
	
	def write
		# write yaml file of this object
		path = '/Users/donald/Dropbox/AO Thread Crawl/Ruby Port/'
		File.open(path + "parse_history_#{@fNum}.yml", 'w') { |f| f.write self.to_yaml }
	end
	
	def build_history(fnum, init)
		# the real initialize method
		tcat = read("thread_cat_#{fnum}")
		tcat.each do |k, v|
			if v > 0
				# political initial time:
				#init = Time.new(2016,06,24,21,14,0)
				@threadTimes[k] = [init]
				@threadPosts[k] = [v]
			end
		end
	end
	
	def update(thread, posts, time)
		# func to add/update 
		@updateTimes.push(time) unless @updateTimes.include?(time)
		if @threadPosts.include?(thread)
			@threadTimes[thread].push(time)
			@threadPosts[thread].push(posts)
		else
			@threadTimes[thread] = [time]
			@threadPosts[thread] = [posts]
		end
	end
end