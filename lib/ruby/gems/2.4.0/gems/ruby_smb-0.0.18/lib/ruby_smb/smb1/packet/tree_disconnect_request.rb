module RubySMB
  module SMB1
    module Packet

      # This class represents an SMB1 TreeDisonnect Request Packet as defined in
      # [2.2.4.51.1 Request](https://msdn.microsoft.com/en-us/library/ee441622.aspx)
      class TreeDisconnectRequest < RubySMB::GenericPacket

        # The Parameter Block for this packet is empty save the Word Count
        class ParameterBlock < RubySMB::SMB1::ParameterBlock
        end

        # The Data Block for this packet is empty save the Byte Count
        class DataBlock < RubySMB::SMB1::DataBlock
        end

        smb_header        :smb_header
        parameter_block   :parameter_block
        data_block        :data_block

        def initialize_instance
          super
          smb_header.command = RubySMB::SMB1::Commands::SMB_COM_TREE_DISCONNECT
        end

      end
    end
  end
end