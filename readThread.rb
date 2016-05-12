require 'net/http'
require 'uri'
require 'yaml'
require 'cgi'

class MyThread
	ATTRS = [:tTitle, :tUrl, :tOP, :tPosts, :tNum]
	attr_reader(*ATTRS)
		
	def initialize(tnum)
		@tNum = tnum
		@tUrl = build_url(tnum, 1)
		@tPosts = []
		@tPostLog = []
		page = get_page(@tUrl)
		build_thread(page, 1)
		@tTitle = get_title(page)
		@curDate = DateTime.now
		@tOP = @tPosts[0].pPoster
	end
	
	def write()
		path = '/Users/donald/Dropbox/AO Thread Crawl/Ruby Port/Threads/'
		File.open(path + "#{@tNum}.yml", 'w') { |f| f.write self.to_yaml }
	end
	
	def curDate
		return @curDate.strftime("%-m/%-d/%Y %l:%M %p")
	end
	
	private # all subsequent methods are private to the class
	
	def build_url(tnum, pageNum)
		server = "http://www.actuarialoutpost.com/"
    	tbase = "actuarial_discussion_forum/showthread.php?t="
    	url = server + tbase + tnum.to_s
    	url = url + "&pp=40&page=" + pageNum.to_s
    	return url
	end
	
	def get_page(url)
		return Net::HTTP.get(URI.parse(url))
	end
	
	def get_title(page)
		start_link = page.index('<title')
    	return nil if start_link == nil
    	start_quote = page.index('>', start_link) + 1 
    	end_quote = page.index('</title>', start_quote)
    	return page[start_quote...end_quote]
	end
	
	def build_thread(page, pageNum)
		# main loop to iterate over every page and load 
		# inner loop to parse the page into an array of Posts
		while page do
			while page do
				meta, post, endpos, pnum = get_next_post(page)
				if post
					return nil if @tPostLog.include?(pnum)
					@tPosts.push(Post.new(pnum, post, meta))
					@tPostLog.push(pnum)
				end
				break if endpos == nil
				page = page[endpos + 1..-1]
			end
			pageNum += 1
			page = get_page(build_url(@tNum, pageNum))
		end
	end
	
	def get_next_post(page)
		# parses post into metadata, post, and post number.
		# most important function is to find the END of the post to 
		# feed the next iteration of the major thread building loop.
		# other parsing could be better handled in the Post Class.
		# this is an arifact of the original Python code.
		start_link = page.index('post_message_')
		return nil, nil, nil, nil if start_link == nil
		meta = page[0...start_link]

		start_pnum = page.index('e_', start_link)
		end_pnum = page.index('"', start_link)
		pnum = page[start_pnum + 2...end_pnum].to_i
		
		start_quote = page.index('>', start_link)
    	end_quote = page.index('<!-- / message -->', start_quote + 1)
    	post = page[start_quote + 1...end_quote]
		
		#ic = Iconv.new('UTF-8', 'WINDOWS-1252')
		#post = post.encode("WINDOWS-1252", :invalid => :replace, :undef => :replace, :replace => "******post can't decode******")
		post = CGI.unescapeHTML(post)
		
		return meta, post, end_quote, pnum
	end
	
	
	
end

class Post
	ATTRS = [:pNum, :pPoster, :pPost, :pQuoted]
	attr_reader(*ATTRS)
	
	def initialize(pnum, post, meta)
		@pNum = pnum  				#refers to the AO post number. Not the thread post number.
		@pPoster = get_poster(meta)
		@pTime = get_timestamp(meta)
		@pQuoted = get_quoted(post)
		@pPost = clean_posts(post)
	end
	
	def pTime
		return @pTime.strftime("%-m/%-d/%Y %l:%M %p")
	end
	
	private # all subsequent methods are private to the class
	
	def clean_posts(post)
		# takes html-free post and parses it back togther with one space per word.
		# guards against improperly concatenating text together in sister method clean_string
		words = clean_string(post).split()
		polished = ''
		words.each { |word| polished += word + ' ' }
		return polished
	end
	
	def clean_string(post)
		# loops through the post text and strips out the html garbage
		start_link = 0
		while true do
			start_link = post.index('<')
			return post if start_link == nil
			end_quote = post.index('>', start_link + 1)
			if post[start_link...start_link + 25] == '<img src="images/smilies/'
				end_smilie = post.index('" ', start_link)
				smilie = '{' + post[start_link + 25...end_smilie] + '}'
			else
				smilie = ''
			end
			post = post[0...start_link] + smilie + post[end_quote + 1..-1]
		end 
		return post
	end 
	
	def get_poster(post)
		start_link = post.index('<a class="bigusername"')
		return nil if start_link == nil
		start_quote = post.index('>', start_link) + 1
    	end_quote = post.index('</a>', start_quote)
    	return post[start_quote...end_quote]
	end
	
	def get_timestamp(post)
		start_link = post.index('<!-- status icon and date -->')
		return nil if start_link == nil
		start_quote = post.index('</a>', start_link) + 1
    	end_quote = post.index('<!-- / status icon and date -->', start_quote)
    	return parse_date(post[start_quote + 4...end_quote].strip)
	end
	
	def parse_date(tstamp) 
		# takes string date and creates DateTime object
		if tstamp[0,9] == 'Yesterday'
			now = DateTime.now - 24 * 60 * 60
			time = DateTime.strptime(tstamp[11,8], "%H:%M %p")
		elsif tstamp[0,5] == 'Today'
			now = DateTime.now
			time = DateTime.strptime(tstamp[7,8], "%H:%M %p")
		else
			return DateTime.strptime(tstamp, "%m-%d-%Y, %H:%M %p")
		end
		return DateTime.new(now.year, now.month, now.day, time.hour, time.minute, 0)
	end
	
	def get_quoted(post)
		posters = Hash.new()
		while true do
			start_link = post.index('<strong>')
			return posters if start_link == nil
			# find name of quoted poster
			start_quote = post.index('>', start_link) + 1
			end_quote = post.index('</strong>', start_quote)
			poster = post[start_quote...end_quote]
			
			# find post# of quoted post
			start_quote = post.index('<a href="showthread.php?p=', end_quote + 1)
			if start_quote
				end_quote = post.index('#', start_quote)
				qnum = post[start_quote + 26...end_quote]
			end
			
			posters[poster] = qnum.to_i
			post = post[end_quote + 1..-1]
		end
		return posters
	end
	
end

def DontRunMain()
	
	#bump = MyThread.new(101562)
	#bernie_banner = MyThread.new(305864)
	snowflake = MyThread.new(306303)
	#puts snowflake.tPosts[8].pQuoted
	#snowflake.write()
	#who_posted(bernie_banner)

end

#DontRunMain()