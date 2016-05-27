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
		write(self, "thread_dict_#{@fNum}")
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
						@tTimesUnq.push(mt.pTime)
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