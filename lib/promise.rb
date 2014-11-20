require "promise/version"

class Promise

  def self.all(promises)
    Promise.new do |fulfill, reject|
      results = []
      success = ->(result) do
        results << result
        fulfill.call(results) if results.size == promises.size
      end
      promises.each do |promise|
        promise.then(success, reject)
      end
    end
  end

  def self.any(promises)
    Promise.new do |fulfill, reject|
      count = promises.size
      on_error = ->(*) do
        count -= 1
        reject.call if count == 0
      end
      # For each promise, let it fulfill this promise,
      # if it fulfills. Otherwise, if all *promises come in rejected,
      # reject this promise.
      promises.each do |promise|
        promise.then(fulfill, on_error)
      end
    end
  end

  def self.start(value)
    Promise.new(false) { |fulfill, _| fulfill.call(value) }
  end

  def self.chain(&block)
    Promise.new do |fulfill, _|
      fulfill.call(yield)
    end
  end

public

  def chain(&block)
    self.then(->(value) {
      Promise.chain { block.call(value) }
    })
  end

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

  def fulfill(value)
    return unless @state == :pending
    @state = :fulfilled
    @value = value
    resolve_steps
  end

  def fulfilled?
    @state == :fulfilled
  end

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

  def pending?
    @state == :pending
  end

  def reject(value)
    return unless @state == :pending
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

    if result.is_a? Promise
      # We have a promise that is still executing, so we need to tell it
      # what to do when complete
      result.then(step[:fulfill], step[:reject])
    else
      # We have a value (not a promise!) so we simply reuse the promise we
      # constructed in then when the "call" was originally setup. Our step has
      # the resolve and reject methods from that promise.
      (fulfilled? ? step[:fulfill] : step[:reject]).call result
    end
  end

  def resolve_steps
    @pending_steps.each { |step| resolve(step) }
    @pending_steps = nil
  end

  def value
    @value
  end
end
