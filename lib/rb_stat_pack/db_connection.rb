module RbStatPack
    class DBConnection
        @conn = nil
        @type = nil

        def initialize(type, dbname, cast_types: true)
            @type = type
            if type == :psql
                @conn = PG.connect(dbname: dbname)
                @conn.type_map_for_results = PG::BasicTypeMapForResults.new(@conn) if cast_types
            end
        end

        def sql(query)
            if @type == :psql
                RbStatPack::DataSet.new(@conn.exec(query))
            end
        end
    end
end