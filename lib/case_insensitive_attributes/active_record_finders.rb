module CaseInsensitiveAttributes
  module ActiveRecordFinders
    def self.extended(klass)
      klass.class_eval do
        class << self
          alias_method_chain :replace_bind_variables, :postgres_case_insensitivity
          alias_method_chain :replace_named_bind_variables, :postgres_case_insensitivity
        end
      end
    end

    def replace_bind_variables_with_postgres_case_insensitivity(*args)
      args = prepare_sql_binding_arguments('(\?)', args)
      replace_bind_variables_without_postgres_case_insensitivity(*args)
    end

    def replace_named_bind_variables_with_postgres_case_insensitivity(*args)
      args = prepare_sql_binding_arguments(':([a-zA-Z]\w*)', args)
      replace_named_bind_variables_without_postgres_case_insensitivity(*args)
    end

    def prepare_sql_binding_arguments(binder_regex, args)
      statement = args.first.dup
      values = args.last.dup

      # converts:
      #   'foo = ? AND bar = ? AND buzz = 7 AND bizz = :b'
      # to:
      #   [["foo", "?"], ["bar", "?"], ["bizz", "b"]]
      columns_with_binder = statement.scan(/([^=\?\s+]+)\s*=\s*#{binder_regex}/)

      columns_with_binder.each_with_index do |column_with_binder, i|
        column_name, binder = *column_with_binder
        collection_key = binder == '?' ? i : binder.to_sym

        if (val = values[collection_key]).is_a?(String)
          column = extract_column_from_column_name(column_name)
          if column && should_use_case_insensitive_condition?(column)
            statement.gsub!(column_name, "LOWER(#{column_name})")
            values[collection_key] = val.mb_chars.downcase
          end
        end
      end

      [statement, values]
    end

    def extract_column_from_column_name(column_name)
      model_class = if column_name =~ /(\w+)[^\w]+(\w+)/ # i.e. tablename.column_name
        column_name = $2
        begin
          model_class = $1.classify.constantize
        rescue NameError
          nil
        end
      end
      model_class ||= self

      model_class.columns.detect { |c| c.name == column_name }
    end

    def should_use_case_insensitive_condition?(column)
      column.text?
    end
  end
end