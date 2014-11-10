require './lib/promise'
on_success = ->(x) { x + 'succeed...' }
on_error = ->(x) { x + 'error...' }
exception = ->(x) { raise 'Oops!' }

# Basic .then
Promise.fulfilled('Start...').then(on_success, on_error).then(on_error, on_success)
Promise.rejected('Start...').then(on_success, on_error).then(on_error, on_success)

nested_success = ->(value) do
  Promise.new do |fulfill, reject|
    fulfill.call on_success.call(value)
  end.then(on_success).then(exception)
end
Promise.fulfilled('Start...').then(nested_success, on_error).then(on_error)
