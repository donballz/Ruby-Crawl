require 'rubygems'
require 'mechanize'

agent = Mechanize.new
page = agent.get('http://www.actuarialoutpost.com/actuarial_discussion_forum/index.php')
login = page.form_with(:action => "login.php?do=login")
login.vb_login_username = 'ADoggieDetective'
login.vb_login_password = 'H2A5cVQzT28wCLx#'
agent.submit(login, login.buttons.first)

pol = agent.get('http://www.actuarialoutpost.com/actuarial_discussion_forum/forumdisplay.php?f=23')

# From forum page, build list of unique threads
threads, links = [], []
pol.links.each do |l|
	uriStr = l.uri.to_s 
	begl = uriStr.index('showthread.php?t=')
	if begl != nil
		endl = uriStr.index('&', begl+1)
		endl = 0 if endl == nil
		t = uriStr[begl+17..endl-1]
		unless threads.include?(t)
			threads.push(t)
			links.push(l)
		end
	end
end

links.each { |t| pp t.uri }