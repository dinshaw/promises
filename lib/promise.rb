# require "promise/version"

class Promise

  def self.fulfilled(value)
    Promise.new(false) { |fulfill, _| fulfill.call(value) }
  end

  def self.rejected(value)
    Promise.new(false) { |_, reject| reject.call(value) }
  end

public

  def then(on_success, on_error = nil)
    on_success ||= ->(x) {x}
    on_error ||= ->(x) {x}

    Promise.new(false) do |fulfill, reject|
      step = {
        fulfill: fulfill,
        reject: reject,
        on_success: on_success,
        on_error: on_error
      }
      if pending?
        @pending_steps << step
      else
        resolve step
      end
    end
  end

private

  def initialize(async = true)
    @state = :pending
    @value = nil
    @pending_steps = []
    exec = -> do
      begin
        yield method(:fulfill), method(:reject)
      rescue Exception => e
        reject(e)
      end
    end
    async ? Thread.new(&exec) : exec.call
  end

  def fulfill(value)
    # p "fulfilling with #{value}"
    @state = :fulfilled
    @value = value
    resolve_steps
  end

  def fulfilled?
    @state == :fulfilled
  end

  def pending?
    @state == :pending
  end

  def reject(value)
    # p "rejecting with #{value}"
    @state = :rejected
    @value = value
    resolve_steps
  end

  def rejected?
    @state == :rejected
  end

  def resolve(step)
    callback = fulfilled? ? step[:on_success] : step[:on_error]
    result = callback.call(@value)
    # result =
    #   begin
    #     # The callback may return a regular value, a promise,
    #     # or raise an exception.
    #     callback.call(@value)
    #   rescue Exception => e
    #     # This exception might come back from a callback (success or failure).
    #     # We assume raised exceptions are errors and so we wrap it in a rejected
    #     # promise to force the next promise to be in a rejected case.
    #     Promise.rejected(e)
    #   end

    if Promise === result
      puts 'Promise'
      # We have a promise so we need to link that promise with one we already
      # constructed inside then. This can be done by using then (although it's
      # not super efficient since we create a 3rd promise (!!!) that acts as the
      # go between for result and the step's promise from then).
      result.then(step[:fulfill], step[:reject])
    else
      # We have a value (not a promise!) so we simply reuse the promise we
      # constructe in then when the "call" was original setup. Our step has
      # the resolve and reject methods from that promise.
      (fulfilled? ? step[:fulfill] : step[:reject]).call(result)
    end
  end

  def resolve_steps
    @pending_steps.each { |step| resolve(step) }
    @pending_steps = nil
  end
end
