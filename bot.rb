require 'rubygems'
require 'blather/client'

accepted_users = ["robert.jung@tolingo.com", "goosebuster@gmail.com"]

setup 'botolingo@googlemail.com', 'funnybot123', 'talk.google.com', 5222, "./cert"
when_ready {
	puts "Connected ! send messages to #{jid.stripped}."
}

subscription :request? do |s|
	write_to_stream s.approve!
end

message :chat?, :body => 'exit' do |m|
    say m.from, 'Exiting ...'
	shutdown
end

message :chat?, :body => /^time$/ do |m|
	say m.from, Time.now.to_s
end

message :chat?, :body => /^exec .*/ do |m|
	m.body.match /^exec (.*)/
	pid = fork {
		system $1
		puts $1.to_s # logger
	}
	Process.detach(pid)
	say m.from, "You executed: #{$1}"
end

message :chat?, :body do |m|
    sender = m.from.to_s.split(/\//).first
    unless accepted_users.include? sender
		say m.from, "I'm afraid I don't know you yet, " + sender
	else
		say m.from, "Sorry, don't know what \"#{m.body}\" means!"
	end
end
