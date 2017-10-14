module RubySMB
  module SMB1

    # An SMB1 connected remote Tree, as returned by a
    # [RubySMB::SMB1::Packet::TreeConnectRequest]
    class Tree

      # The client this Tree is connected through
      # @!attribute [rw] client
      #   @return [RubySMB::Client]
      attr_accessor :client

      # The current Guest Share Permissions
      # @!attribute [rw] guest_permissions
      #   @return [RubySMB::SMB1::BitField::DirectoryAccessMask]
      attr_accessor :guest_permissions

      # The current Maximal Share Permissions
      # @!attribute [rw] permissions
      #   @return [RubySMB::SMB1::BitField::DirectoryAccessMask]
      attr_accessor :permissions

      # The share path associated with this Tree
      # @!attribute [rw] share
      #   @return [String]
      attr_accessor :share

      # The Tree ID for this Tree
      # @!attribute [rw] id
      #   @return [Integer]
      attr_accessor :id

      def initialize(client:, share:, response:)
        @client             = client
        @share              = share
        @id                 = response.smb_header.tid
        @guest_permissions  = response.parameter_block.guest_access_rights
        @permissions        = response.parameter_block.access_rights
      end

      # Disconnects this Tree from the current session
      #
      # @return [WindowsError::ErrorCode] the NTStatus sent back by the server.
      def disconnect!
        request = RubySMB::SMB1::Packet::TreeDisconnectRequest.new
        request.smb_header.tid = self.id
        raw_response = self.client.send_recv(request)
        response = RubySMB::SMB1::Packet::TreeDisconnectResponse.read(raw_response)
        response.status_code
      end


    end
  end
end