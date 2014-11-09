require 'spec_helper'

describe Promise do
  let(:promise) do
    Promise.new do |fulfill, reject|
      value = do_something.call
      fulfill.call value
    end
  end

  describe 'initialization' do
    let(:promise) { Promise.new {|_,_| } }
    it 'sets state to :pending' do
      expect(promise.pending?).to eq true
    end

    it 'sets value to nil' do
      expect(promise.instance_variable_get("@value")).to be_nil
    end
  end

  context 'on successful execution' do
    let(:do_something) { -> { 'Successful!' } }

    it 'fulfills the promise' do
      expect(promise.fulfilled?).to eq true
    end
  end

  context 'on exception during execution' do
    let(:do_something) { -> { raise 'Oops!'} }

    it 'rejects the promise' do
      expect(promise.rejected?).to eq true
    end
  end
end
