module RubySMB
  module SMB1
    module Packet

      # This class represents an SMB1 TreeConnect Request Packet as defined in
      # [2.2.4.7.1 Client Request Extensions](https://msdn.microsoft.com/en-us/library/cc246330.aspx)
      class TreeConnectRequest < RubySMB::GenericPacket

        # A SMB1 Parameter Block as defined by the {TreeConnectRequest}
        class ParameterBlock < RubySMB::SMB1::ParameterBlock
          and_x_block          :andx_block
          tree_connect_flags   :flags
          uint16               :password_length, label: 'Password Length', initial_value: 0x01
        end

        class DataBlock < RubySMB::SMB1::DataBlock
          stringz  :password, label: 'Password Field', initial_value: '',    length: lambda { self.parent.parameter_block.password_length }
          stringz  :path,     label: 'Resource Path'
          stringz  :service,  label: 'Resource Type',  initial_value: '?????'
        end

        smb_header        :smb_header
        parameter_block   :parameter_block
        data_block        :data_block

        def initialize_instance
          super
          smb_header.command = RubySMB::SMB1::Commands::SMB_COM_TREE_CONNECT
        end

      end
    end
  end
end