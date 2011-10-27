require 'rubygems'
require 'blather/client'

accepted_users = ["robert.jung@tolingo.com", "goosebucccster@gmail.com"]

setup 'botolingo@googlemail.com', 'funnybot123', 'talk.google.com', 5222, "./cert"
when_ready {
  puts "Connected ! send messages to #{jid.stripped}."
}
disconnected { client.connect }


before(:message) { |m| puts m.inspect}
before(:subscrition) { |m| write_to_stream s.unsubscribe! unless accepted_users.include?(s.from.stripped.to_s); puts "go away!" }





subscription :request? do |s|
  sender = s.from.stripped.to_s
  if accepted_users.include? sender
    write_to_stream s.approve!
  else
   # say s.from, "I'm afraid I don't know you yet, " + sender + ", please introduce yourself to my owner!"
    write_to_stream s.refuse!
  end
end

# message :chat? do |m|
#   puts m.inspect
#   false # fall through
# end

message :chat?, :body => /^deploy .*?/ do |m|
  m.body.match /^deploy ([^ ]*) ([^ ]*)/
  output = IO.popen("cd #{$1}; echo 'cd `pwd`'; echo 'cap #{$2} deploy'", "r") { |pipe| output = pipe.read }
  say m.from, "#{output}"
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
  output = IO.popen("#{$1}", "r") { |pipe| output = pipe.read }
  say m.from, "#{output}"
end

message :chat?, :body do |m|
  say m.from, "Sorry, don't know what \"#{m.body}\" means!"
end
