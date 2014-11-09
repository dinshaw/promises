require "promise/version"

class Promise

  def fulfilled?
    @state == :fulfilled
  end

  def pending?
    @state == :pending
  end

  def rejected?
    @state == :rejected
  end

private

  def initialize
    @state = :pending
    begin
      yield method(:fulfill)
    rescue Exception => e
      reject(e)
    end
  end

  def fulfill(value)
    @state = :fulfilled
  end

  def reject(value)
    @state = :rejected
  end

end
