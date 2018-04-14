require 'rubygems'
require 'mechanize'

agent = Mechanize.new
page = agent.get('http://www.actuarialoutpost.com/actuarial_discussion_forum/index.php')
login = page.form_with(:action => "login.php?do=login")
login.vb_login_username = 'ADoggieDetective'
login.vb_login_password = 'H2A5cVQzT28wCLx#'
agent.submit(login, login.buttons.first)

bump = agent.get('http://www.actuarialoutpost.com/actuarial_discussion_forum/showthread.php?t=101562')
#pp bump.forms
post = bump.form_with(:name => "vbform")
post.message = ":bump:"
agent.submit(post, post.buttons.first)