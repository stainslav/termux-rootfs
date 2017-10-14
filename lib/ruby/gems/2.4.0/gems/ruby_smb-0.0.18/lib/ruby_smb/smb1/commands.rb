module RubySMB
  module SMB1
    module Commands
      SMB_COM_ECHO                    = 0x2B
      SMB_COM_TRANSACTION2            = 0x32
      SMB_COM_TRANSACTION2_SECONDARY  = 0x33
      SMB_COM_TREE_DISCONNECT         = 0x71
      SMB_COM_NEGOTIATE               = 0x72
      SMB_COM_SESSION_SETUP           = 0x73
      SMB_COM_LOGOFF                  = 0x74
      SMB_COM_TREE_CONNECT            = 0x75
      SMB_COM_NT_TRANSACT             = 0xA0
      SMB_COM_NO_ANDX_COMMAND         = 0xFF
    end
  end
end
