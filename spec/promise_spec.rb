require 'spec_helper'

describe Promise do
  context 'initialization' do
    let(:promise) { Promise.new(false) {} }
    it 'sets state to :pending' do
      expect(promise.send :pending?).to eq true
    end

    it 'sets value to nil' do
      expect(promise.instance_variable_get("@value")).to be_nil
    end

    context 'with a long running process' do
      let(:promise) do
        Promise.new do |fulfill, reject|
          sleep 2
          fulfill('All rested!')
        end
      end

      it 'backgrounds the process' do
        expect(Thread).to receive :new
        promise
      end
    end
  end

  context 'on successful fulfillment' do
    let(:promise) { Promise.fulfilled(99) }

    it 'returns a Promise' do
      expect(promise).to be_a Promise
    end

    it 'sets state to :fulfilled' do
      expect(promise.send :fulfilled?).to eq true
    end

    it 'sets @value' do
      expect(promise.instance_variable_get "@value").to eq 99
    end
  end

  context 'on exception during fulfillment' do
    let(:promise) do
      Promise.new(false) do |fulfill|
        fulfill.call ->{ raise RuntimeError.new }.call
      end
    end

    it 'sets state to :rejected' do
      expect(promise.send :rejected?).to eq true
    end

    it 'sets @value' do
      expect(promise.instance_variable_get "@value").to be_a RuntimeError
    end
  end

  describe '.then' do
    let(:proc) { -> { 'Call me, please...' } }

    context 'when fulfilled' do
      let(:promise) { Promise.fulfilled('x') }
      it 'executes ->on_success' do
        expect(proc).to receive :call
        promise.then(proc)
      end
    end

    context 'when rejected' do
      let(:promise) { Promise.rejected('x') }
      it 'executes ->on_error' do
        expect(proc).to receive :call
        promise.then(->{}, proc)
      end
    end
  end
end
