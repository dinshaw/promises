require 'spec_helper'

describe Promise do
  let(:on_success) { ->(value) { [value,'succeeded'].join(' ') } }
  let(:on_error) { ->(value) { [value, 'failed'].join(' ') } }
  let(:value) { promise.instance_variable_get("@value") }

  context 'initialization' do
    let(:promise) { Promise.new(false) {} }
    it 'sets state to :pending' do
      expect(promise.send :pending?).to eq true
    end

    it 'sets value to nil' do
      expect(value).to be_nil
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

  describe '#then' do
    context 'when fulfilled' do
      let(:promise) { Promise.fulfilled('fulfilled').then(on_success, on_error) }

      it 'executes ->on_success' do
        expect(value).to eq 'fulfilled succeeded'
      end

      it 'returns a promise' do
        expect(promise).to be_a Promise
      end
    end

    context 'when rejected' do
      let(:promise) { Promise.rejected('rejected').then(on_success, on_error) }

      it 'executes ->on_error' do
        expect(value).to eq 'rejected failed'
      end

      it 'returns a promise' do
        expect(promise).to be_a Promise
      end
    end

    context 'with a nested Promise' do
      let(:promise) { Promise.fulfilled('fulfilled').then(on_success, on_error) }
      let(:on_success) do
        ->(value) {
          Promise.new { |fulfill, reject|
            fulfill.call [value, 'nesting succeeded'].join(' ')
          }.then(->(value) { [value, 'and so did I!'].join(' ')})
        }
      end
      it 'adds the next step to the new Promise' do
        expect(value).to eq 'fulfilled nesting succeeded and so did I!'
      end
    end
  end



end


