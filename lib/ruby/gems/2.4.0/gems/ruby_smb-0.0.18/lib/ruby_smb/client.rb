module RubySMB

  # Represents an SMB client capable of talking to SMB1 or SMB2 servers and handling
  # all end-user client functionality.
  class Client
    require 'ruby_smb/client/negotiation'
    require 'ruby_smb/client/authentication'
    require 'ruby_smb/client/signing'
    require 'ruby_smb/client/tree_connect'
    require 'ruby_smb/client/echo'

    include RubySMB::Client::Negotiation
    include RubySMB::Client::Authentication
    include RubySMB::Client::Signing
    include RubySMB::Client::TreeConnect
    include RubySMB::Client::Echo

    # The Default SMB1 Dialect string used in an SMB1 Negotiate Request
    SMB1_DIALECT_SMB1_DEFAULT = "NT LM 0.12"
    # The Default SMB2 Dialect string used in an SMB1 Negotiate Request
    SMB1_DIALECT_SMB2_DEFAULT = "SMB 2.002"
    # Dialect value for SMB2 Default (Version 2.02)
    SMB2_DIALECT_DEFAULT = 0x0202


    # The dispatcher responsible for sending packets
    # @!attribute [rw] dispatcher
    #   @return [RubySMB::Dispatcher::Socket]
    attr_accessor :dispatcher

    # The domain you're trying to authenticate to
    # @!attribute [rw] domain
    #   @return [String]
    attr_accessor :domain

    # The local workstation to pretend to be
    # @!attribute [rw] local_workstation
    #   @return [String]
    attr_accessor :local_workstation

    # The NTLM client used for authentication
    # @!attribute [rw] ntlm_client
    #   @return [String]
    attr_accessor :ntlm_client

    # The password to authenticate with
    # @!attribute [rw] password
    #   @return [String]
    attr_accessor :password

    # The Native OS of the Peer/Server.
    # Currently only available with SMB1.
    # @!attribute [rw] peer_native_os
    #   @return [String]
    attr_accessor :peer_native_os

    # The Sequence Counter used for SMB1 Signing.
    # It tracks the number of packets both sent and received
    # since the NTLM session was initialized with the Challenge.
    # @!attribute [rw] sequence_counter
    #   @return [Integer]
    attr_accessor :sequence_counter

    # The current Session ID setup by authentication
    # @!attribute [rw] session_id
    #   @return [Integer]
    attr_accessor :session_id

    # Whether or not the Server requires signing
    # @!attribute [rw] signing_enabled
    #   @return [Boolean]
    attr_accessor :signing_required

    # Whether or not the Client should support SMB1
    # @!attribute [rw] smb1
    #   @return [Boolean]
    attr_accessor :smb1

    # Whether or not the Client should support SMB2
    # @!attribute [rw] smb2
    #   @return [Boolean]
    attr_accessor :smb2

    #  Tracks the current SMB2 Message ID that keeps communication in sync
    # @!attribute [rw] smb2_message_id
    #   @return [Integer]
    attr_accessor :smb2_message_id

    # The username to authenticate with
    # @!attribute [rw] username
    #   @return [String]
    attr_accessor :username

    # The UID set in SMB1
    # @!attribute [rw] user_id
    #   @return [String]
    attr_accessor :user_id

    # @param dispatcher [RubySMB::Dispacther::Socket] the packet dispatcher to use
    # @param smb1 [Boolean] whether or not to enable SMB1 support
    # @param smb2 [Boolean] whether or not to enable SMB2 support
    def initialize(dispatcher, smb1: true, smb2: true, username:,password:, domain:'.', local_workstation:'WORKSTATION')
      raise ArgumentError, 'No Dispatcher provided' unless dispatcher.kind_of? RubySMB::Dispatcher::Base
      if smb1 == false && smb2 == false
        raise ArgumentError, 'You must enable at least one Protocol'
      end
      @dispatcher        = dispatcher
      @domain            = domain
      @local_workstation = local_workstation
      @password          = password.encode("utf-8") || ''.encode("utf-8")
      @sequence_counter  = 0
      @session_id        = 0x00
      @session_key       = ''
      @signing_required  = false
      @smb1              = smb1
      @smb2              = smb2
      @username          = username.encode("utf-8") || ''.encode("utf-8")

      @ntlm_client = Net::NTLM::Client.new(
        @username,
        @password,
        workstation: @local_workstation,
        domain: @domain
      )

      @smb2_message_id = 0
    end

    # Logs off any currently open session on the server
    # and closes the TCP socket connection.
    #
    # @return [void]
    def disconnect!
      begin
        logoff!
      rescue
        wipe_state!
      end
      dispatcher.tcp_socket.close
    end

    # Sends an Echo request to the server and returns the
    # NTStatus of the last response packet received.
    #
    # @param echo [Integer] the number of times the server should echo (ignored in SMB2)
    # @param data [String] the data the server should echo back (ignored in SMB2)
    # @return [WindowsError::ErrorCode] the NTStatus of the last response received
    def echo(count: 1, data: '' )
      if smb2
        response = smb2_echo
      else
        response = smb1_echo(count:count, data:data)
      end
      response.status_code
    end

    # Sets the message id field in an SMB2 packet's
    # header to the one tracked by the client. It then increments
    # the counter on the client.
    #
    # @param packet [RubySMB::GenericPacket] the packet to set the message id for
    # @return [RubySMB::GenericPacket] the modified packet
    def increment_smb_message_id(packet)
      if packet.smb2_header.message_id == 0 && self.smb2_message_id != 0
        packet.smb2_header.message_id = self.smb2_message_id
        self.smb2_message_id += 1
      end
      packet
    end

    # Performs protocol negotiation and session setup. It defaults to using
    # the credentials supplied during initialization, but can take a new set of credentials if needed.
    def login(username: self.username, password: self.password, domain: self.domain, local_workstation: self.local_workstation )
      @domain            = domain
      @local_workstation = local_workstation
      @password          = password.encode("utf-8") || ''.encode("utf-8")
      @username          = username.encode("utf-8") || ''.encode("utf-8")

      @ntlm_client = Net::NTLM::Client.new(
        @username,
        @password,
        workstation: @local_workstation,
        domain: @domain
      )

      negotiate
      authenticate
    end

    # Sends a LOGOFF command to the remote server to terminate the session
    #
    # @return [WindowsError::ErrorCode] the NTStatus of the response
    def logoff!
      if smb2
        request      = RubySMB::SMB2::Packet::LogoffRequest.new
        raw_response = send_recv(request)
        response     = RubySMB::SMB2::Packet::LogoffResponse.read(raw_response)
      else
        request      = RubySMB::SMB1::Packet::LogoffRequest.new
        raw_response = send_recv(request)
        response     = RubySMB::SMB1::Packet::LogoffResponse.read(raw_response)
      end
      wipe_state!
      response.status_code
    end

    # Sends a packet and receives the raw response through the Dispatcher.
    # It will also sign the packet if neccessary.
    #
    # @param packet [RubySMB::GenericPacket] the request to be sent
    # @return [String] the raw response data received
    def send_recv(packet)
      case packet.packet_smb_version
        when 'SMB1'
          if self.user_id
            packet.smb_header.uid = self.user_id
          end
          packet = smb1_sign(packet)
        when 'SMB2'
          packet = increment_smb_message_id(packet)
          packet.smb2_header.session_id = self.session_id
          unless packet.is_a?(RubySMB::SMB2::Packet::SessionSetupRequest)
            packet = smb2_sign(packet)
          end
        else
          packet = packet
      end
      dispatcher.send_packet(packet)
      raw_response = dispatcher.recv_packet

      if self.signing_required && !self.session_key.empty?
        self.sequence_counter += 1
      end
      raw_response
    end

    # Connects to the supplied share
    #
    # @param share [String] the path to the share in `\\server\share_name` format
    # @return [RubySMB::SMB1::Tree] if talking over SMB1
    # @return [RubySMB::SMB2::Tree] if talking over SMB2
    def tree_connect(share)
      if smb2
        smb2_tree_connect(share)
      else
        smb1_tree_connect(share)
      end
    end

    # Resets all of the session state on the client, setting it
    # back to scratch. Should only be called when a session is no longer
    # valid.
    #
    # @return [void]
    def wipe_state!
      self.session_id       = 0x00
      self.user_id          = 0x00
      self.session_key      = ''
      self.sequence_counter = 0
      self.smb2_message_id  = 0
    end


  end
end
