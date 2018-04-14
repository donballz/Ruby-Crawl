require 'rubygems'
require 'mechanize'

agent = Mechanize.new
page = agent.get('http://www.actuarialoutpost.com/actuarial_discussion_forum/index.php')
login = page.form_with(:action => "login.php?do=login")
login.vb_login_username = 'ADoggieDetective'
login.vb_login_password = 'H2A5cVQzT28wCLx#'
agent.submit(login, login.buttons.first)

pol = agent.get('http://www.actuarialoutpost.com/actuarial_discussion_forum/forumdisplay.php?f=23')

#pp pol.links_with(:text => 'showthread.php?t=')
threads = []
pol.links.each do |l|
	p l.uri.to_s
	#if l.uri.to_s.find('showthread.php?t=') != -1
	#	threads.push(l)
	#end
end

#threads.each { |t| pp t }