module DatabaseRewinder
  module InsertRecorder
    def execute(sql, *)
      DatabaseRewinder.record_inserted_table self, sql
      super
    end

    def exec_query(sql, *)
      DatabaseRewinder.record_inserted_table self, sql
      super
    end

    module Hook
      def establish_connection(*)
        super
        Hook.apply!
      end

      def self.apply!
        ::ActiveRecord::ConnectionAdapters::SQLite3Adapter.send :prepend, InsertRecorder if defined? ::ActiveRecord::ConnectionAdapters::SQLite3Adapter
        ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.send :prepend, InsertRecorder if defined? ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
        ::ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter.send :prepend, InsertRecorder if defined? ::ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter
      end
    end
  end
end

DatabaseRewinder::InsertRecorder::Hook.apply!
ActiveRecord::Base.singleton_class.send(:prepend, DatabaseRewinder::InsertRecorder::Hook)
