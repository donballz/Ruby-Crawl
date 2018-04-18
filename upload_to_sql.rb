require_relative 'readThread.rb'
require_relative 'threadDict.rb'

STICKY = [280594, 310192]

def build_col_types(con, tbl)
	# gets column types from information_schema and parses into array for insert query
	rows = con.query "SELECT DATA_TYPE AS TYPE FROM INFORMATION_SCHEMA.COLUMNS
					WHERE TABLE_SCHEMA = '#{SCMA}' AND TABLE_NAME = '#{tbl}';"
	col_types = []
	rows.each { |row| col_types.push(row['TYPE']) }
	return col_types
end

def row_to_string(row, cols)
	# converts row to string for upload to mysql
	str = "("
	for i in 0...cols.length
		if cols[i] == 'varchar'
			if row[i] == '' or row[i] == nil
				str += "'NA',"
			else
				str += "'#{row[i].to_s.gsub("'", "`")}'," 
			end
		elsif cols[i] == 'datetime'
			str += "'#{row[i].to_s[0,19]}',"
		else
			if row[i] == '' or row[i] == nil
				str += "0,"
			else
				str += "#{row[i].to_i}," 
			end
		end
	end
	return str[0...-1] + ")"
end

def up_to_sql(con, t, first, last)
	# uploads processed yaml file to given sql table
	thread_cols = build_col_types(con, 'THREADS')
	post_cols = build_col_types(con, 'POSTS')
	row = [t.tNum, t.tTitle, t.tOP, t.tPosts[0].pTime, first, last]
	str = row_to_string(row, thread_cols)
	con.query("INSERT INTO THREADS VALUES #{str}")
	cnt = 1
	t.each do |post|
		if post.pQuoted.length > 3
			mq = 'Y'
		else
			mq = 'N'
		end
		q1, q2, q3 = ' ', ' ', ' '
		q1n, q2n, q3n = 0, 0, 0
		if post.pQuoted.length > 0
			q1 = post.pQuoted.keys[0]
			q1n = post.pQuoted[q1]
		end
		if post.pQuoted.length > 1
			q2 = post.pQuoted.keys[1]
			q2n = post.pQuoted[q2]
		end
		if post.pQuoted.length > 2
			q3 = post.pQuoted.keys[2]
			q3n = post.pQuoted[q3]
		end
		row = [post.pNum, t.tNum, cnt, post.pPoster, post.pTime, q1, q1n, q2, q2n, q3, q3n, mq]
		str = row_to_string(row, post_cols)
		con.query("INSERT INTO POSTS VALUES #{str}")
		cnt += 1
	end
	return nil
end

def upload_threads(fnum, con)
	# function reads thread catalog and gets any files found to be missing
	puts 'retreiving parse history...'
	phist = read("parse_history_#{fnum}")
	puts 'retrieving thread catalog...'
	tcat = read("thread_cat_#{fnum}")
	time = Time.now
	ok, lost = 0, 0
	tcat.each do |k ,v|
		if File.exist?("#{PATH}/Threads/#{k}.yml")
			puts "uploading thread #{k}..."
			parsed = read("Threads/#{k}")
			up_to_sql(con, parsed, phist.threadTimes[k][0], phist.threadTimes[k][-1])
			ok += 1
		else
			lost += 1
		end
	end
	puts "#{ok} threads were uploaded"
	puts "#{lost} threads are lost"
	return time
end

begin
	key = File.read("#{PATH}/key.txt")
	con = Mysql2::Client.new(:host => SRVR, :username => USER, :password => PSWD.decrypt(key))
	con.query("USE #{SCMA}")
	
	time = Time.now
	loaded = upload_threads(23, con)
	puts "Time to load #{loaded - time}"
	puts "Time to parse #{Time.now - time}"

rescue Mysql2::Error => e
	puts e.errno
	puts e.error

ensure
	con.close if con
end