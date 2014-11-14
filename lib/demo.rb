require 'promise'

Promise.start('Garfield')
Promise.start('Garfield').then(->(x){p x})
Promise.start('Garfield').then(->(x){ x+' the cat'}).then(->(x){ x+' is lazy'})

# Exceptions
Promise.start('Garfield').
  then(->(x){ raise 'No cat pics!'}).
  then(_, ->(x){'Alert! '+x.message})

# Async ... but first ...
# Constructor - what has .start been doing?
Promise.start('Garfield')
Promise.new(false) { |fulfill, reject|
  fulfill.call('Garfield')
}

# Fulfill / Reject slide...

# Async
Promise.new { |fulfill, reject|
  fulfill.call('Garfield')
}

# Things of note: Returns immediately
pr = Promise.new { |fulfill, reject|
  sleep 5
  fulfill.call('Garfield')
}
watch pr

# Async - Sync
Promise.new { |fulfill, reject|
  sleep 5
  fulfill.call('Garfield')
}.then(->(x){p x + ' the cat.'})

# Lets get a little more involved

promises = %w(CAT PUG BABY).map do |meme|
  Promise.new { |fulfill, _|
    x = rand(10)
    sleep x
    fulfill.call("#{meme} slept #{x}")
  }.then(->(y) { y + ', then woke up.' })
end; nil
watch_many promises

# all
promises = %w(CAT PUG BABY).map do |meme|
  Promise.new { |fulfill, _|
    x = rand(10)
    sleep x
    fulfill.call( p "#{meme} slept #{x}")
  }.then(->(y) { y + ", then woke up.\n" })
end; nil
Promise.all(*promises).then(->(x) { print "Everyone is up: \n#{x.join}"}); nil

# separate...

# Implementation of .all

# Any / race
def race
  memes = %w(Cat Pug Baby)

  promises = memes.map { |meme|
    Promise.new do |fulfill, reject|
      x = rand(5)
      sleep x; fulfill.call("#{meme} slept #{x}, ")
    end
  } << Promise.new { sleep 3; raise 'Took too long!' }
  Promise.any(*promises).then(->(val) { puts val })
  nil
end

# Implementation of any
