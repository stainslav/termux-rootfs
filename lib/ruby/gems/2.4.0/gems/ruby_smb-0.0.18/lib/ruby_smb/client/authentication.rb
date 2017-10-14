module RubySMB
  class Client
    # This module holds all the backend client methods for authentication.
    module Authentication

      # Responsible for handling Authentication and Session Setup for
      # the SMB Client. It returns the final Status code from the authentication
      # exchange.
      #
      # @return [WindowsError::NTStatus] the NTStatus object from the SessionSetup exchange.
      def authenticate
        if self.smb1
          if self.username.empty? && self.password.empty?
            smb1_anonymous_auth
          else
            smb1_authenticate
          end
        else
          smb2_authenticate
        end
      end

      #
      # SMB1 Methods
      #

      # Attempts an Anonymous logon to the remote server.
      #
      # @return [WindowsError::ErrorCode] the status code the server returned
      def smb1_anonymous_auth
        request       = smb1_anonymous_auth_request
        raw_response  = send_recv(request)
        response      = smb1_anonymous_auth_response(raw_response)
        response_code = response.status_code

        if response_code.name == "STATUS_SUCCESS"
          self.user_id  = response.smb_header.uid
          self.peer_native_os = response.data_block.native_os
        end

        response_code
      end

      # Creates a {SessionSetupRequest} for an anonymous
      # access session.
      def smb1_anonymous_auth_request
        packet = RubySMB::SMB1::Packet::SessionSetupLegacyRequest.new
        packet.data_block.oem_password = "\x00"
        packet.parameter_block.max_buffer_size = 4356
        packet.parameter_block.max_mpx_count = 50
        packet.parameter_block.capabilities.extended_security = 0
        packet
      end

      def smb1_anonymous_auth_response(raw_response)
        begin
          packet = RubySMB::SMB1::Packet::SessionSetupLegacyResponse.read(raw_response)
        rescue
          packet = RubySMB::SMB1::Packet::EmptyPacket.read(raw_response)
        end

        unless packet.smb_header.command == RubySMB::SMB1::Commands::SMB_COM_SESSION_SETUP
          raise RubySMB::Error::InvalidPacket, "Command was #{packet.smb_header.command} and not #{RubySMB::SMB1::Commands::SMB_COM_SESSION_SETUP}"
        end
        packet
      end

      # Handles the SMB1 NTLMSSP 4-way handshake for Authentication
      def smb1_authenticate
        response = smb1_ntlmssp_negotiate
        challenge_packet = smb1_ntlmssp_challenge_packet(response)
        user_id = challenge_packet.smb_header.uid
        challenge_message = smb1_type2_message(challenge_packet)
        raw = smb1_ntlmssp_authenticate(challenge_message, user_id)
        response = smb1_ntlmssp_final_packet(raw)
        response_code = response.status_code

        if response_code.name == "STATUS_SUCCESS"
          self.user_id  = user_id
          self.peer_native_os = response.data_block.native_os
        end

        response_code
      end

      # Sends the {RubySMB::SMB1::Packet::SessionSetupRequest} packet and
      # receives the response.
      #
      # @return [String] the binary string response from the server
      def smb1_ntlmssp_negotiate
        packet = smb1_ntlmssp_negotiate_packet
        send_recv(packet)
      end

      # Takes the Base64 encoded NTLM Type 2 (Challenge) message
      # and calls the routines to build the Auth packet, sends the packet
      # and receives the raw response
      #
      # @param type2_string [String] the Base64 Encoded NTLM Type 2 message
      # @param user_id [Integer] the temporary user ID from the Type 2 response
      # @return [String] the raw binary response from the server
      def smb1_ntlmssp_authenticate(type2_string,user_id)
        packet = smb1_ntlmssp_auth_packet(type2_string,user_id)
        send_recv(packet)
      end

      # Generates the {RubySMB::SMB1::Packet::SessionSetupRequest} packet
      # with the NTLM Type 3 (Auth) message in the security_blob field.
      #
      # @param type2_string [String] the Base64 encoded Type2 challenge to respond to
      # @param user_id [Integer] the temporary user ID from the Type 2 response
      # @return [RubySMB::SMB1::Packet::SessionSetupRequest] the second authentication packet to send
      def smb1_ntlmssp_auth_packet(type2_string,user_id)
        type3_message = ntlm_client.init_context(type2_string)
        self.session_key = ntlm_client.session_key
        packet = RubySMB::SMB1::Packet::SessionSetupRequest.new
        packet.smb_header.uid = user_id
        packet.set_type3_blob(type3_message.serialize)
        packet.parameter_block.max_buffer_size = 4356
        packet.parameter_block.max_mpx_count = 50
        packet.smb_header.flags2.extended_security = 1
        packet
      end

      # Creates the {RubySMB::SMB1::Packet::SessionSetupRequest} packet
      # for the first part of the NTLMSSP 4-way hnadshake. This packet
      # initializes negotiations for the NTLMSSP authentication
      #
      # @return [RubySMB::SMB1::Packet::SessionSetupRequest] the first authentication packet to send
      def smb1_ntlmssp_negotiate_packet
        type1_message = ntlm_client.init_context
        packet = RubySMB::SMB1::Packet::SessionSetupRequest.new
        packet.set_type1_blob(type1_message.serialize)
        packet.parameter_block.max_buffer_size = 4356
        packet.parameter_block.max_mpx_count = 50
        packet.smb_header.flags2.extended_security = 1
        packet
      end

      # Takes the raw binary string and returns a {RubySMB::SMB1::Packet::SessionSetupResponse}
      def smb1_ntlmssp_final_packet(raw_response)
        begin
          packet = RubySMB::SMB1::Packet::SessionSetupResponse.read(raw_response)
        rescue
          packet = RubySMB::SMB1::Packet::EmptyPacket.read(raw_response)
        end

        unless packet.smb_header.command == RubySMB::SMB1::Commands::SMB_COM_SESSION_SETUP
          raise RubySMB::Error::InvalidPacket, "Command was #{packet.smb_header.command} and not #{RubySMB::SMB1::Commands::SMB_COM_SESSION_SETUP}"
        end
        packet
      end

      # Takes the raw binary string and returns a {RubySMB::SMB1::Packet::SessionSetupResponse}
      def smb1_ntlmssp_challenge_packet(raw_response)
        packet = RubySMB::SMB1::Packet::SessionSetupResponse.read(raw_response)
        status_code = packet.status_code

        unless status_code.name == "STATUS_MORE_PROCESSING_REQUIRED"
          raise RubySMB::Error::UnexpectedStatusCode, status_code.to_s
        end

        unless packet.smb_header.command == RubySMB::SMB1::Commands::SMB_COM_SESSION_SETUP
          raise RubySMB::Error::InvalidPacket, "Command was #{packet.smb_header.command} and not #{RubySMB::SMB1::Commands::SMB_COM_SESSION_SETUP}"
        end
        packet
      end

      # Parses out the NTLM Type 2 Message from a {RubySMB::SMB1::Packet::SessionSetupResponse}
      #
      # @param response_packet [RubySMB::SMB1::Packet::SessionSetupResponse] the response packet to get the NTLM challenge from
      # @return [String] the base64 encoded  NTLM Challenge (Type2 Message) from the response
      def smb1_type2_message(response_packet)
        sec_blob = response_packet.data_block.security_blob
        ntlmssp_offset = sec_blob.index("NTLMSSP")
        type2_blob = sec_blob.slice(ntlmssp_offset..-1)
        [type2_blob].pack("m")
      end

      #
      # SMB 2 Methods
      #

      # Handles the SMB1 NTLMSSP 4-way handshake for Authentication
      def smb2_authenticate
        response = smb2_ntlmssp_negotiate
        challenge_packet = smb2_ntlmssp_challenge_packet(response)
        session_id = challenge_packet.smb2_header.session_id
        self.session_id = session_id
        challenge_message = smb2_type2_message(challenge_packet)
        raw = smb2_ntlmssp_authenticate(challenge_message, session_id)
        response = smb2_ntlmssp_final_packet(raw)
        response.status_code
      end

      # Takes the raw binary string and returns a {RubySMB::SMB2::Packet::SessionSetupResponse}
      def smb2_ntlmssp_final_packet(raw_response)
        packet = RubySMB::SMB2::Packet::SessionSetupResponse.read(raw_response)
        unless packet.smb2_header.command == RubySMB::SMB2::Commands::SESSION_SETUP
          raise RubySMB::Error::InvalidPacket, "Command was #{packet.smb2_header.command} and not #{RubySMB::SMB2::Commands::SESSION_SETUP}"
        end
        packet
      end

      # Takes the raw binary string and returns a {RubySMB::SMB2::Packet::SessionSetupResponse}
      def smb2_ntlmssp_challenge_packet(raw_response)
        packet = RubySMB::SMB2::Packet::SessionSetupResponse.read(raw_response)
        status_code = packet.status_code
        unless status_code.name == "STATUS_MORE_PROCESSING_REQUIRED"
          raise RubySMB::Error::UnexpectedStatusCode, status_code.to_s
        end

        unless packet.smb2_header.command == RubySMB::SMB2::Commands::SESSION_SETUP
          raise RubySMB::Error::InvalidPacket, "Command was #{packet.smb2_header.command} and not #{RubySMB::SMB2::Commands::SESSION_SETUP}"
        end
        packet
      end

      # Sends the {RubySMB::SMB2::Packet::SessionSetupRequest} packet and
      # receives the response.
      #
      # @return [String] the binary string response from the server
      def smb2_ntlmssp_negotiate
        packet = smb2_ntlmssp_negotiate_packet
        send_recv(packet)
      end

      # Creates the {RubySMB::SMB2::Packet::SessionSetupRequest} packet
      # for the first part of the NTLMSSP 4-way handshake. This packet
      # initializes negotiations for the NTLMSSP authentication
      #
      # @return [RubySMB::SMB2::Packet::SessionSetupRequest] the first authentication packet to send
      def smb2_ntlmssp_negotiate_packet
        type1_message = ntlm_client.init_context
        packet = RubySMB::SMB2::Packet::SessionSetupRequest.new
        packet.set_type1_blob(type1_message.serialize)
        # This Message ID should always be 1, but thanks to Multi-Protocol Negotiation
        # the Message ID can be out of sync at this point so we re-synch it here.
        packet.smb2_header.message_id = 1
        self.smb2_message_id = 2
        packet
      end

      # Parses out the NTLM Type 2 Message from a {RubySMB::SMB2::Packet::SessionSetupResponse}
      #
      # @param response_packet [RubySMB::SMB2::Packet::SessionSetupResponse] the response packet to get the NTLM challenge from
      # @return [String] the base64 encoded  NTLM Challenge (Type2 Message) from the response
      def smb2_type2_message(response_packet)
        sec_blob = response_packet.buffer
        ntlmssp_offset = sec_blob.index("NTLMSSP")
        type2_blob = sec_blob.slice(ntlmssp_offset..-1)
        [type2_blob].pack("m")
      end

      # Takes the Base64 encoded NTLM Type 2 (Challenge) message
      # and calls the routines to build the Auth packet, sends the packet
      # and receives the raw response
      #
      # @param type2_string [String] the Base64 Encoded NTLM Type 2 message
      # @param user_id [Integer] the temporary user ID from the Type 2 response
      # @return [String] the raw binary response from the server
      def smb2_ntlmssp_authenticate(type2_string,user_id)
        packet = smb2_ntlmssp_auth_packet(type2_string,user_id)
        send_recv(packet)
      end

      # Generates the {RubySMB::SMB2::Packet::SessionSetupRequest} packet
      # with the NTLM Type 3 (Auth) message in the security_blob field.
      #
      # @param type2_string [String] the Base64 encoded Type2 challenge to respond to
      # @param session_id [Integer] the temporary session id from the Type 2 response
      # @return [RubySMB::SMB2::Packet::SessionSetupRequest] the second authentication packet to send
      def smb2_ntlmssp_auth_packet(type2_string, session_id)
        type3_message = ntlm_client.init_context(type2_string)
        self.session_key = ntlm_client.session_key
        packet = RubySMB::SMB2::Packet::SessionSetupRequest.new
        packet.smb2_header.session_id = session_id
        packet.set_type3_blob(type3_message.serialize)
        packet
      end


    end
  end
end