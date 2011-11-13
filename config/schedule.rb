set :output, "/dev/null"

every 2.days, :at => '2:43 pm' do
  rake "execute"
end
