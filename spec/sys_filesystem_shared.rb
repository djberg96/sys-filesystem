# frozen_string_literal: true

require 'sys-filesystem'

RSpec.shared_examples Sys::Filesystem do
  example 'version number is set to the expected value' do
    expect(Sys::Filesystem::VERSION).to eq('1.5.5')
    expect(Sys::Filesystem::VERSION).to be_frozen
  end

  example 'you cannot instantiate an instance' do
    expect{ described_class.new }.to raise_error(NoMethodError)
  end
end
