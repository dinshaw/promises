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
