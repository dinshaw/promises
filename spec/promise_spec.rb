require 'spec_helper'

describe Promise do
  describe 'initialization' do
    let(:promise) { Promise.new {} }
    it 'sets state to :pending' do
      expect(promise.send :pending?).to eq true
    end

    it 'sets value to nil' do
      expect(promise.instance_variable_get("@value")).to be_nil
    end
  end

  describe '.fulfilled' do
    let(:promise) { Promise.fulfilled(99) }
    it 'returns a Promise' do
      expect(promise).to be_a Promise
    end

    it 'fulfills the promise' do
      expect(promise.send :fulfilled?).to eq true
    end
  end

  context 'on successful execution' do
    let(:promise) do
      Promise.new do |fulfill|
        fulfill.call ->{ 'Successful!' }.call
      end
    end

    it 'fulfills the promise' do
      expect(promise.send :fulfilled?).to eq true
    end

    it 'sets the value' do
      expect(promise.instance_variable_get "@value").to eq 'Successful!'
    end
  end

  context 'on exception during execution' do
    let(:promise) do
      Promise.new do |fulfill|
        fulfill.call ->{ raise RuntimeError.new }.call
      end
    end

    it 'rejects the promise' do
      expect(promise.send :rejected?).to eq true
    end

    it 'sets the value' do
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
