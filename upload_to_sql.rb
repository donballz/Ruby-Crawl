require_relative 'readThread.rb'

begin
	key = File.read("#{PATH}/key.txt")
	con = Mysql.new SRVR, USER, PSWD.decrypt(key)
	con.query("USE #{SCMA}")
	rows = sql_qry('games_to_upload', con)

	rows.each_hash do |row|
		game = row['BOX_SCORE_TEXT'] 
		puts "processing #{game}"
		if row['BS_COMPLETE'] == '1' and row['BS_UPLOAD'] == '0'
			basic, advanced = bs_post(game, YAMP)
			up_to_sql(con, basic, 'NBA_GAME_STATS_BASIC')
			up_to_sql(con, advanced, 'NBA_GAME_STATS_ADV')
			con.query("UPDATE NBA_GAME_LIST_UPLOAD SET BS_COMPLETE = 1 WHERE GAME_ID = '#{game}'")
		end
		
		if row['PBP_COMPLETE'] == '1' and row['PBP_UPLOAD'] == '0'
			pbp =  pbp_post(game, YAMP)
			up_to_sql(con, pbp, 'NBA_GAME_PBP')
			con.query("UPDATE NBA_GAME_LIST_UPLOAD SET PBP_COMPLETE = 1 WHERE GAME_ID = '#{game}'")
		end
		
		if row['PM_COMPLETE'] == '1' and row['PM_UPLOAD'] == '0'
			pm = pm_post(game, YAMP)
			up_to_sql(con, pm, 'NBA_GAME_PLUS_MINUS')
			con.query("UPDATE NBA_GAME_LIST_UPLOAD SET PM_COMPLETE = 1 WHERE GAME_ID = '#{game}'")
		end
	end

rescue Mysql::Error => e
	puts e.errno
	puts e.error

ensure
	con.close if con
end