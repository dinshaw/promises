require './lib/promise'
pr = Promise.fulfilled('x').then(->(x) { x + 'Success!' }, ->(x) { X + 'Fail!'})

nested_promise = ->(value) do
  Promise.new {|fulfill, reject|
    fulfill.call(value + 'Hello')
  }
end
pr = Promise.fulfilled('x').then(nested_promise, ->(x) { X + 'Fail!'})
