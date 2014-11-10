require './brians_promise'
require './lib/promise'

on_success = ->(x) { x + 'succeed...' }
on_error = ->(x) { x.message + 'error...' }
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
on_success = ->(value) do
  Promise.new(false) { |fulfill, reject|
    raise 'Oops!'
  }
end
Promise.fulfilled('Start...').then(on_success, nil).then(nil, on_error)
