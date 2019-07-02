# frozen_string_literal: true

# allow to use nulldb adapter
module ActiveRecord
  module ConnectionAdapters
    class NullDBAdapter < ActiveRecord::ConnectionAdapters::AbstractAdapter
      def new_table_definition(table_name = nil, is_temporary = nil)
        TableDefinition.new(table_name, is_temporary)
      end
    end
  end
end
