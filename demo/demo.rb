require 'promise'

Promise.start('Garfield')
Promise.start('Garfield').then(->(x){p x})
Promise.start('Garfield').then(->(x){ x+' the cat'}).then(->(x){ x+' is lazy'})
_.then(->(x){x+' and fat!'})

# Exceptions
Promise.start('Garfield').
  then(->(x){ raise 'Garfield sucks.'}).
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
watch Promise.new { |fulfill, reject|
  sleep 5
  fulfill.call('Garfield')
}

# Async - Sync
Promise.new { |fulfill, reject|
  sleep 5
  fulfill.call('Garfield')
}.then(->(x){p x + ' the cat.'})

# Lets get a little more involved

promises = %w(Garfield Felix Grumpy).map do |meme|
  Promise.new { |fulfill, _|
    x = rand(10)
    sleep x
    fulfill.call("#{meme} slept #{x}")
  }.then(->(y) { y + ', then woke up.' })
end; nil
watch_many promises

# all
promises = %w(Garfield Felix Grumpy).map do |meme|
  Promise.new { |fulfill, _|
    x = rand(10)
    sleep x
    fulfill.call( p "#{meme} slept #{x}")
  }.then(->(y) { y + ", then woke up.\n" })
end; nil
Promise.all(promises).then(->(x) { puts "Everyone is up: \n#{x.join}"}); nil

# separate...

# Implementation of .all

# Any / race
def race
  promises = %w(Cat Pug Baby).map { |meme|
    Promise.new do |fulfill, reject|
      x = rand(8)
      sleep x; fulfill.call("#{meme} slept #{x}")
    end
  }
  Promise.any(*promises).then(->(x){p x})
  nil
end

# Implementation of any
