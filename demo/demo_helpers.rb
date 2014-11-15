def get_cat_pic(n)
  sleep(n)
end

def watch(x)
  while x.pending? do
    print x.inspect + "\r"
  end
  print x.inspect
  print "\n"
end

def watch_many(promises)
  while true do
    values = promises.map(&:value)
    print "#{values}\r"
    break if values.compact.size == promises.size
  end
  print "\n"
end
