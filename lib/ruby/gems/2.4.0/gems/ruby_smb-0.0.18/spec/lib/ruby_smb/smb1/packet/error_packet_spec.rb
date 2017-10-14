require 'spec_helper'

RSpec.describe RubySMB::SMB1::Packet::EmptyPacket do
  subject(:packet) { described_class.new }

  describe '#smb_header' do
    subject(:header) { packet.smb_header }

    it 'is a standard SMB Header' do
      expect(header).to be_a RubySMB::SMB1::SMBHeader
    end

  end

  describe '#parameter_block' do
    subject(:parameter_block) { packet.parameter_block }

    it 'is a standard ParameterBlock' do
      expect(parameter_block).to be_a RubySMB::SMB1::ParameterBlock
    end

    it 'should be empty' do
      expect(parameter_block.to_binary_s).to eq "\x00"
    end
  end

  describe '#data_block' do
    subject(:data_block) { packet.data_block }

    it 'is a standard DataBlock' do
      expect(data_block).to be_a RubySMB::SMB1::DataBlock
    end

    it 'should be empty' do
      expect(data_block.to_binary_s).to eq "\x00\x00"
    end
  end

end