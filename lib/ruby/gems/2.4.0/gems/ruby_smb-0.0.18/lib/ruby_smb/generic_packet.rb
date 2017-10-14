module RubySMB
  # Parent class for all SMB Packets.
  class GenericPacket < BinData::Record
    # Outputs a nicely formatted string representation
    # of the Packet's structure.
    #
    # @return [String] formatted string representation of the packet structure
    def self.describe
      description = ''
      fields_hashed.each do |field|
        description << format_field(field)
      end
      description
    end

    def display
      display_str = ''
      self.class.fields_hashed.each do |field|
        display_str << display_field(field)
      end
      display_str
    end


    def packet_smb_version
      class_name = self.class.to_s
      case class_name
        when /SMB1/
          'SMB1'
        when /SMB2/
          'SMB2'
        else
          ''
      end
    end

    def status_code
      value = -1
      smb_version = packet_smb_version
      case smb_version
        when 'SMB1'
          value = self.smb_header.nt_status.value
        when 'SMB2'
          value = self.smb2_header.nt_status.value
      end
      status_code = WindowsError::NTStatus.find_by_retval(value).first
      if status_code.nil?
        status_code = WindowsError::ErrorCode.new("0x#{value.to_s(16)}", value, "Unknown 0x#{value.to_s(16)}")
      end
      status_code
    end

    private

    # Returns an array of hashes representing the
    # fields for this record.
    #
    # @return [Array<Hash>] the array of hash representations of the record's fields
    def self.fields_hashed
      walk_fields(fields)
    end

    # Takes a hash representation of a field and spits out a formatted
    # string representation.
    #
    # @param field [Hash] the hash representing the field
    # @param depth [Fixnum] the recursive depth level to track indentation
    # @return [String] the formatted string representation of the field
    def self.format_field(field, depth = 0)
      name = field[:name].to_s
      if field[:class].ancestors.include? BinData::Record
        class_str = ''
        name.upcase!
      else
        class_str = field[:class].to_s.split('::').last
        class_str = "(#{class_str})"
        name.capitalize!
      end
      formatted_name = "\n" + ("\t" * depth) + name
      formatted_string = sprintf '%-30s %-10s %s', formatted_name, class_str, field[:label]
      field[:fields].each do |sub_field|
        formatted_string << format_field(sub_field, (depth + 1))
      end
      formatted_string
    end

    # Recursively walks through a field, building a hash representation
    # of that field and all of it's sub-fields.
    #
    # @param fields [Array<BinData::SanitizedField>] an array of fields to walk
    # @return [Array<Hash>] an array of hashes representing the fields
    def self.walk_fields(fields)
      field_hashes = []
      fields.each do |field|
        field_hash = {}
        field_hash[:name] = field.name
        prototype = field.prototype
        field_hash[:class] = prototype.instance_variable_get(:@obj_class)
        params = prototype.instance_variable_get(:@obj_params)
        field_hash[:label] = params[:label]
        field_hash[:value] = params[:value]
        sub_fields = params[:fields]
        field_hash[:fields] = if sub_fields.nil?
                                []
                              else
                                walk_fields(sub_fields)
                              end
        field_hashes << field_hash
      end
      field_hashes
    end

    # Takes a hash representation of a field in the packet structure and formats it
    # into a string representing the contents of that field.
    #
    # @param field [Hash] hash representation of the field to display
    # @param depth [Fixnum] the recursion depth for setting indent levels
    # @param parents [Array<Symbol>] the name of the parent field, if any, of this field
    # @return [String] a formatted string representing the field and it's current contents
    def display_field(field, depth = 0, parents = [])
      my_parents = parents.dup
      field_str = ''
      name = field[:name]
      if field[:class] == BinData::Array
        field_str = "\n" + ("\t" * depth) + name.to_s.upcase
        parent = self
        my_parents.each do |pfield|
          parent = parent.send(pfield)
        end
        array_field = parent.send(name)
        field_str << process_array_field(array_field, (depth + 1))
      else
        if my_parents.empty?
          label = "\n" + ("\t" * depth) + name.to_s.upcase
          if field[:class].ancestors.include? BinData::Record
            field_str = label
          else
            value = self.send(name)
            field_str = sprintf '%-30s %s', label, value
          end
        else
          parent = self
          my_parents.each do |pfield|
            parent = parent.send(pfield)
          end
          value = parent.send(name)
          label = field[:label] || name.to_s.capitalize
          label = "\n" + ("\t" * depth) + label
          field_str = sprintf '%-30s %s', label, value
        end
      end
      my_parents << name
      field[:fields].each do |sub_field|
        field_str << display_field(sub_field, (depth + 1), my_parents)
      end
      field_str
    end

    # Takes a {BinData::Array} field and processes it to get
    # the structure elements and values out since they cannot be
    # evaluated at the class level.
    #
    # @param array_field [BinData::Array] the Array field to be processed
    # @return [String] the formatted string representing the contents of the array
    def process_array_field(array_field, depth)
      array_field_str = ''
      array_field.each do |sub_field|
        fields = sub_field.class.fields.raw_fields
        sub_field_hashes = self.class.walk_fields(fields)
        sub_field_hashes.each do |sub_field_hash|
          name = sub_field_hash[:name]
          label = sub_field_hash[:label]
          value = sub_field.send(name)
          label ||= name
          label = "\n" + "\t" * depth + label
          sub_field_str = sprintf '%-30s %s', label, value
          array_field_str << sub_field_str
        end
      end
      array_field_str
    end
  end
end
