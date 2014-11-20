require 'spec_helper'

describe Promise do
  let(:on_success) { ->(value) { [value, 'succeeded'].join(' ') } }
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

    context 'async execution' do
      it 'is on by default' do
        expect(Thread).to receive :new
        Promise.new { 'Hello' }
      end

      it 'can be turned off' do
        expect(Thread).not_to receive :new
        Promise.new(false) { 'Hello' }
      end
    end
  end

  context 'on successful fulfillment' do
    let(:promise) { Promise.start(99) }

    it 'returns a Promise' do
      expect(promise).to be_a Promise
    end

    it 'sets state to :fulfilled' do
      expect(promise.send :fulfilled?).to eq true
    end

    it 'sets @value' do
      expect(value).to eq 99
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
      expect(value).to be_a RuntimeError
    end
  end

  describe '#chain' do
    it 'allows simple chaining of promises' do
      promise = \
        Promise.
          chain { sleep 0.1; 5 }.
          chain { |n| sleep 0.1; n + 5 }.
          chain { |n| sleep 0.1; n + 5 }

      sleep 0.5
      expect(promise.send(:value)).to eq 15
      expect(promise.send(:fulfilled?)).to eq true
    end
  end

  describe '#then' do
    let(:promise) { Promise.start('fulfilled').then(on_success, on_error) }

    context 'when fulfilled' do
      it 'executes ->on_success' do
        expect(value).to eq 'fulfilled succeeded'
      end

      it 'returns a promise' do
        expect(promise).to be_a Promise
      end

      context 'and next step raises' do
        let(:on_success) { ->(x) { raise 'Oops!' } }

        it 'sets @value to the exception' do
          expect(value).to be_a RuntimeError
        end

        it 'sets state to :rejected' do
          expect(promise.send :rejected?).to eq true
        end
      end
    end

    context 'when rejected' do
      let(:promise) do
        Promise.new(false) { |_,reject|
          reject.call('rejected')
        }.then(on_success, on_error)
      end

      it 'executes ->on_error' do
        expect(value).to eq 'rejected failed'
      end

      it 'returns a promise' do
        expect(promise).to be_a Promise
      end
    end

    context 'with a nested Promise' do
      let(:promise) { Promise.start('fulfilled').then(on_success, on_error) }

      context 'that succeeds' do
        let(:on_success) do
          ->(value) {
            Promise.new(false) { |fulfill, reject|
              fulfill.call [value, 'nesting succeeded'].join(' ')
            }.then(->(value) { [value, 'and so did I!'].join(' ')})
          }
        end

        it 'adds the next step to the new Promise' do
          expect(value).to eq 'fulfilled nesting succeeded and so did I!'
        end
      end

      context 'that raises' do
        let(:on_error) { ->(value) { [value, 'but I did not...'].join(' ')} }
        let(:on_success) do
          ->(val) {
            Promise.new(false) {
              raise 'Oops!'
            }.then(nil, on_error )
          }
        end

        it 'adds the next step to the new Promise' do
          expect(value).to eq 'Oops! but I did not...'
        end
      end
    end
  end


  describe '.all' do
    let(:promises) do
      [1, 2, 3].map {|n|
        Promise.new do |resolve, reject|
          resolve.call(n)
        end
      }
    end

    let(:promise) do
      Promise.all(promises).then(->(val) { "#{val.size} promises resolved!"})
    end

    before { promise; sleep 1 }

    it 'waits for all promises to resolve' do
      expect(value).to eq "#{promises.size} promises resolved!"
    end
  end

  describe '.any' do
    let(:promises) do
      [1, 2].map do |n|
        Promise.new do |resolve, reject|
          resolve.call(n)
        end
      end
    end

    let(:promise) { Promise.any(promises) }

    before { promise; sleep 1 }

    it 'returns the value of the first Promise to resolve' do
      expect(value).to be_a Integer
    end
  end
end

