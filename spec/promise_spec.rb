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
    let(:promise) { Promise.fulfilled(99) }

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

  describe '#then' do
    let(:promise) { Promise.fulfilled('fulfilled').then(on_success, on_error) }

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
end
