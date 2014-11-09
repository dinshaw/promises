require 'thread'

class Promise

  def self.all(*promises)
    Promise.new do |resolve, reject|
      results = []
      success = ->(result) do
        results << result
        resolve.call(results) if results.size == promises.size
      end
      promises.each do |promise|
        promise.then(success, reject)
      end
    end
  end

  def self.any(*promises)
    Promise.new do |resolve, reject|
      count = promises.size
      fail = ->(*) do
        count -= 1
        reject.call if count == 0
      end
      promises.each do |promise|
        promise.then(resolve, fail)
      end
    end
  end

  def self.wait(*promises)
    Promise.new do |resolve, reject|
      results = []
      promises.each do |promise|
        accumulate = ->(*) do
          results << promise
          resolve.call(results) if results.size == promises.size
        end
        promise.then(accumulate, accumulate)
      end
    end
  end

  def self.race(*promises)
    Promise.new do |resolve, reject|
      promises.each do |promise|
        promise.then(resolve, reject)
      end
    end
  end

  def self.rejected(error)
    Promise.new(true) do |_, reject| reject.call(error) end
  end

  def self.resolved(value)
    Promise.new(true) do |resolve, _| resolve.call(value) end
  end

public

  def catch(failure)
    self.then(nil, failure)
  end

  def then(success, failure = nil)
    failure ||= ->(x) {x}
    success ||= ->(x) {x}
    Promise.new do |resolve, reject|
      step = {
        success: success,
        failure: failure,
        resolve: resolve,
        reject: reject}
      if pending? then @pending_steps << step else fulfill(step) end
    end
  end

private

  def fulfill(step)
    # Decide which callback to use based on our current state (assuming we are
    # not pending anymore).
    callback = step[resolved? ? :success : :failure]
    result =
      begin
        # The callback may return a regular value, a promise,
        # or raise an exception.
        callback.call(@value)
      rescue Exception => e
        # This exception might come back from a callback (success or failure).
        # We assume raised exceptions are errors and so we wrap it in a rejected
        # promise to force the next promise to be in a rejected case.
        Promise.rejected(e)
      end
    Promise === result ?
      # We have a promise so we need to link that promise with one we already
      # constructed inside then. This can be done by using then (although it's
      # not super efficient since we create a 3rd promise (!!!) that acts as the
      # go between for result and the step's promise from then).
      result.then(step[:resolve], step[:reject]) :
      # We have a value (not a promise!) so we simply reuse the promise we
      # constructe in then when the "call" was original setup. Our step has
      # the resolve and reject methods from that promise.
      step[resolved? ? :resolve : :reject].call(result)
  end

  def fulfill_steps
    @pending_steps.each do |step| fulfill(step) end
    @pending_steps = nil
  end

  def initialize(immediate = false)
    @state = :pending
    @value = nil
    @pending_steps = []
    @mutex = Mutex.new
    exec = -> do
      begin
        yield(method(:resolve), method(:reject))
      rescue Exception => e
        reject(e)
      end
    end
    # TODO: replace with ThreadPool or use event loop like EM
    immediate ? exec.call : Thread.new(&exec)
  end

  def pending?
    @state == :pending
  end

  def reject(value)
    @mutex.synchronize {
      return unless @state == :pending
      @state = :rejected
    }
    @value = value
    fulfill_steps
  end

  def resolve(value)
    @mutex.synchronize {
      return unless @state == :pending
      @state = :resolved
    }
    @value = value
    fulfill_steps
  end

  def resolved?
    @state == :resolved
  end

end

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
# require 'timeout'
#
# def race
#   ps = [1, 2, 3, 4].map {|n|
#     Promise.new do |resolve, reject|
#       sleep rand(10)
#       resolve.call(n)
#     end
#   }
#   timeout = Promise.new {sleep 8; raise Timeout::Error, "Took to long!"}
#   Promise
#     .any(Promise.all(*ps), timeout)
#     .then(
#       ->((a,b,c,d)) {puts "\ngot #{a} #{b} #{c} #{d}"},
#       ->(err) {p err}
#     )
#   nil
# end
