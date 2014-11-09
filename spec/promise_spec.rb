require 'spec_helper'

describe Promise do
  let(:empty_promise) { Promise.new {} }
  let(:promise) do
    Promise.new do |fulfill|
      value = do_something.call
      fulfill.call value
    end
  end

  describe 'initialization' do
    it 'sets state to :pending' do
      expect(empty_promise.send :pending?).to eq true
    end

    it 'sets value to nil' do
      expect(empty_promise.instance_variable_get("@value")).to be_nil
    end
  end

  describe '.fulfilled' do
    let(:fulfilled_promise) { Promise.fulfilled(99) }
    it 'returns a Promise' do
      expect(fulfilled_promise).to be_a Promise
    end

    it 'fulfills the promise' do
      expect(fulfilled_promise.send :fulfilled?).to eq true
    end
  end

  context 'on successful execution' do
    let(:do_something) { -> { 'Successful!' } }

    it 'fulfills the promise' do
      expect(promise.send :fulfilled?).to eq true
    end

    it 'sets the value' do
      expect(promise.instance_variable_get "@value").to eq 'Successful!'
    end
  end

  context 'on exception during execution' do
    let(:do_something) { -> { raise RuntimeError.new } }

    it 'rejects the promise' do
      expect(promise.send :rejected?).to eq true
    end

    it 'sets the value' do
      expect(promise.instance_variable_get "@value").to be_a RuntimeError
    end
  end

  describe '.then' do
    it 'executes ->on_success' do
      expect(
        empty_promise.then(-> { 'Successful!'} )
      ).to eq 'Successful!'
    end
  end
end
