require "promise/version"

class Promise

  def self.fulfilled(value)
    Promise.new(false) { |fulfill, _| fulfill.call(value) }
  end

  def self.rejected(value)
    Promise.new(false) { |_, reject| reject.call(value) }
  end

public

  def then(on_success, on_error = nil)
    case @state
    when :fulfilled
      on_success.call
    when :rejected
      on_error.call
    end
  end

private

  def initialize(async = true)
    @state = :pending
    exec = -> do
      begin
        yield method(:fulfill)
      rescue Exception => e
        reject(e)
      end
    end
    async ? Thread.new(&exec) : exec.call
  end

  def fulfill(value)
    @state = :fulfilled
    @value = value
  end

  def fulfilled?
    @state == :fulfilled
  end

  def pending?
    @state == :pending
  end


  def reject(value)
    @state = :rejected
    @value = value
  end

  def rejected?
    @state == :rejected
  end
end
