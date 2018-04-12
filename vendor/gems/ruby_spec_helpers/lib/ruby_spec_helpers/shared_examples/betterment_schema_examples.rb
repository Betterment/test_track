RSpec.shared_examples 'a Betterment database schema' do |opts = {}|
  let(:schema_file) { Rails.root.join('db', 'schema.rb') }
  let(:foreign_databases) { opts[:foreign_databases] || [] }
  let(:permitted_non_uuid_table_names) { opts[:permitted_non_uuid_table_names] || [] }
  let(:permitted_non_unique_foreign_database_id_columns) { opts[:permitted_non_unique_foreign_database_id_columns] || [] }
  let(:permitted_id_columns_without_foreign_key_constraint) { opts[:permitted_id_columns_without_foreign_key_constraint] || [] }
  let(:permitted_id_columns_without_index) { opts[:permitted_id_columns_without_index] || [] }
  let(:permitted_non_bigint_cents_columns) { opts[:permitted_non_bigint_cents_columns] || [] }
  let(:permitted_tables_without_timestamps) { opts[:permitted_tables_without_timestamps] || [] }
  let(:permitted_nullable_timestamp_columns) { opts[:permitted_nullable_timestamp_columns] || [] }
  let(:permitted_hmac_columns_without_index) { opts[:permitted_hmac_columns_without_index] || [] }

  it 'should use created_at and updated_at columns on all tables' do
    unmatched_tables = {}
    each_schema_line do |current_table_name, line|
      if line =~ /create_table/
        unmatched_tables[current_table_name] = []
      elsif (timestamp_column = /t\.datetime\s+"((created|updated)_at)"/.match(line)&.[](1))
        unmatched_tables[current_table_name] << timestamp_column
        unmatched_tables.delete(current_table_name) if unmatched_tables[current_table_name].sort == %w(created_at updated_at)
      end
    end
    expect(unmatched_tables.keys - permitted_tables_without_timestamps).to be_empty
  end

  it 'should use non-nullable created_at and updated_at columns' do
    unmatched_columns = Set.new
    each_schema_line do |current_table_name, line|
      column_name = /t\.datetime\s+"((created|updated)_at)"/.match(line)&.[](1)
      if column_name && line !~ /null: false/ && !permitted_nullable_timestamp_columns.include?("#{current_table_name}.#{column_name}")
        unmatched_columns << [current_table_name, column_name]
      end
    end
    expect(unmatched_columns).to be_empty
  end

  it 'should use bigints for all money values' do
    unmatched_columns = Set.new
    each_schema_line do |current_table_name, line|
      column_name = /t\.integer\s+"(.+_cents)"/.match(line)&.[](1)
      if column_name && line !~ /limit: 8/ && !permitted_non_bigint_cents_columns.include?("#{current_table_name}.#{column_name}")
        unmatched_columns << [current_table_name, column_name]
      end
    end
    expect(unmatched_columns).to be_empty
  end

  it 'should use uuids for all new primary keys' do
    unmatched_table_names = Set.new
    each_schema_line do |current_table_name, line|
      next unless line =~ /create_table/ &&
          !permitted_non_uuid_table_names.include?(current_table_name) &&
          !line.match(/id: :uuid/) &&
          !line.match(/default: "uuid_generate_v4\(\)"/)
      unmatched_table_names << current_table_name
    end
    expect(unmatched_table_names).to be_empty
  end

  it 'should use unique indices on foreign database keys' do
    unmatched_columns = Set.new
    each_schema_line do |current_table_name, line|
      column_name = /t\.(integer|uuid)\s+"(\S+_(uu)?id)"/.match(line)&.[](2)
      if column_name && foreign_database_column?(column_name)
        unmatched_columns << "#{current_table_name}.#{column_name}"
      elsif (match = /t\.index \["(\S+)"\],.+unique: true, using: :btree/.match(line))
        unmatched_columns.delete("#{current_table_name}.#{match[1]}")
      elsif (match = /add_index "(\S+)", \["(\S+)"\],.+unique: true, using: :btree/.match(line))
        unmatched_columns.delete("#{match[1]}.#{match[2]}")
      end
    end
    expect(unmatched_columns - permitted_non_unique_foreign_database_id_columns).to be_empty
  end

  it 'should use FK constraints on foreign key columns' do
    unmatched_columns = Set.new
    each_schema_line do |current_table_name, line|
      column_name = /t\.(integer|uuid)\s+"(\S+_(uu)?id)"/.match(line)&.[](2)
      if column_name && !foreign_database_column?(column_name)
        unmatched_columns << "#{current_table_name}.#{column_name}"
      elsif (match = /add_foreign_key "(\S+)",.+, column: "(\S+)"/.match(line))
        unmatched_columns.delete("#{match[1]}.#{match[2]}")
      elsif (match = /add_foreign_key "(\S+)", "(\S+)"/.match(line))
        unmatched_columns.delete("#{match[1]}.#{match[2].singularize.foreign_key}")
      end
    end
    expect(unmatched_columns - permitted_id_columns_without_foreign_key_constraint).to be_empty
  end

  it 'should index id columns' do
    unmatched_columns = Set.new
    each_schema_line do |current_table_name, line|
      if (column_name = /t\.(integer|uuid)\s+"(\S+_(uu)?id)"/.match(line)&.[](2))
        unmatched_columns << "#{current_table_name}.#{column_name}"
      elsif (match = /t\.index \["(\S+)"\]/.match(line))
        unmatched_columns.delete("#{current_table_name}.#{match[1]}")
      elsif (match = /add_index "(\S+)", \["(\S+)"\]/.match(line))
        unmatched_columns.delete("#{match[1]}.#{match[2]}")
      end
    end
    expect(unmatched_columns - permitted_id_columns_without_index).to be_empty
  end

  it 'should index hmac columns (UNIQUE or otherwise, depending on the use case)' do
    unmatched_columns = Set.new
    each_schema_line do |current_table_name, line|
      if (column_name = /t\.string\s+"(\S+_hmac)"/.match(line)&.[](1))
        unmatched_columns << "#{current_table_name}.#{column_name}"
      elsif (match = /t\.index \["(\S+)"\]/.match(line))
        unmatched_columns.delete("#{current_table_name}.#{match[1]}")
      elsif (match = /add_index "(\S+)", \["(\S+)"\]/.match(line))
        unmatched_columns.delete("#{match[1]}.#{match[2]}")
      end
    end
    expect(unmatched_columns - permitted_hmac_columns_without_index).to be_empty
  end

  private

  def each_schema_line
    current_table_name = nil
    File.open(schema_file).each do |line|
      if line =~ /create_table/
        current_table_name = line.scan(/create_table "(\w+)"/).first.first
      elsif line !~ /\A\s+t\./
        current_table_name = nil
      end
      yield(current_table_name, line)
    end
  end

  def foreign_database_column?(column_name)
    column_name.start_with?(*foreign_databases) if foreign_databases.any?
  end
end
