require 'promise'
Promise.new{ p 'Hello' }
Promise.new{ sleep 2; p 'Hello' }
Promise.new { |fulfill|  sleep 2; fulfill.call('Fulfilled!') }
Promise.new { |_, reject|  sleep 2; reject.call('Rejected!') }
Promise.new { raise 'EXCEPTION!!' }
Promise.new { sleep 2; raise 'EXCEPTION!!' }.then(_, ->(x) { p x.message } )


# All
memes = %w(Cat Pug Baby)
promises = memes.map do |meme|
  Promise.new { |fulfill|
    x = rand(10)
    sleep x; fulfill.call("#{meme} slept #{x}, ")
  }.then(->(y) {
           msg = y + 'then woke up, '
  } )
end
all_promise = Promise.all(*promises).then(->(x) { "Everyone is up: #{x}"})
while true do; print "#{all_promise.value}\r"; end

  # Any
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


  # ==================================================================================
  # require './brians_promise'
  require './lib/promise'

  on_success = ->(x) { x + 'succeed...' }
  on_error = ->(x) {
    s = x.is_a?(String) ? x : x.message
  s + ': ' + 'error...' }
  exception = ->(x) { raise 'Oops!' }

  # Basic .then()
  Promise.fulfilled('Start...').then(on_success, on_error).then(on_error, on_success)
  Promise.rejected('Start...').then(on_success, on_error).then(on_error, on_success)

  # Nested Promise
  # nested_success = ->(value) do
  #   Promise.new do |fulfill, reject|
  #     fulfill.call on_success.call(value)
  #   end.then(on_success).then(exception)
  # end
  # Promise.fulfilled('Start...').then(nested_success, on_error).then(on_error)

  # Nested with exception
  nested_exception = ->(value) do
    Promise.new(false) { |fulfill, reject|
      exception.call(value)
    }.then(on_success, on_error)
  end
  Promise.fulfilled('Start...').then(nested_exception).then(nil, on_error)
