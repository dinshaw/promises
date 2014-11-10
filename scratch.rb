# require 'thread'


### ASYNC

# resp = Promise.new do |resolve, reject|
#   Thread.new { |;resp|
#     begin
#       resp = HTTP.request(...)
#       resolve(resp.body)
#     rescue
#       reject($!)
#     end
#   }
# end

# ### SYNC

# resp
#   .then(-> {:ok}, -> {Promise.resolved(:err)})
#   .then(->(val) { should be ok or err })

# resp.then(
#   success: ->(body) {
#     "ok"
#   },
#   error: ->(error) {
#     error
#   }
# ).value #=> ok | raise err


# resp.then(
#   success: ->(body) {
#     JSON.parse(body)
#   }
# ).then(
#   success: ->(value) {
#     p = Primise.race(value["urls"].map {|url| fetch(url)})
#       .then(...)
#     p
#   }
# ).tap {this one}.then(
#   success: ->(arr_of_results) { ... }
# )

# # Require Timeout so we can use Timeout::Error
require 'timeout'
require './brians_promise'
def race
  ps = [1, 2, 3, 4].map {|n|
    Promise.new do |resolve, reject|
      sleep rand(10)
      resolve.call(n)
    end
  }
  timeout = Promise.new {sleep 8; raise Timeout::Error, "Took to long!"}
  Promise
    .any(Promise.all(*ps), timeout)
    .then(
      ->((a,b,c,d)) {puts "\ngot #{a} #{b} #{c} #{d}"},
      ->(err) {p err}
    )
  nil
end
