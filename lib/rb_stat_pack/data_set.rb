module RbStatPack
    class DataSet
        include Enumerable
        include CentralTendency

        @data = nil
        @data_type = nil

        @count = nil

        @weight = nil

        def initialize(data, weight: nil)
            @data = data
            @weight = weight

            if Object.const_defined?('ActiveRecord::Relation') && @data.is_a?(ActiveRecord::Relation)
                @data_type = :activerecord_relation
            elsif Object.const_defined?('PG::Result') && @data.is_a?(PG::Result)
                @data_type = :pg_result
            elsif @data.is_a?(Array)
                @data_type = :array
            end

            count
        end

        def weight() @weight end

        def weight=(weight)
            @weight = weight
            count(force: true)
            weight
        end

        def count(force: false)
            return @count if !@count.nil? && !force

            if @weight
                @count = @data.inject(0) { |sum, r| sum + r[@weight] }
            else
                @count = @data.count
            end

            return @count
        end

        def wget(r, f, weight = true)
            if weight
                r[f] * r[@weight]
            else
                r[f]
            end
        end

        def each(&block)
            if @data_type == :activerecord_relation || @data_type == :pg_result || @data_type == :array
                @data.each(&block)
            end
        end

        def min(f)
            retval = nil

            self.each do |r|
                retval = r[f] if r[f] < retval || retval.nil?
            end

            retval
        end

        def max(f)
            retval = nil

            self.each do |r| 
                retval = r[f] if r[f] > retval || retval.nil?
            end

            retval
        end

        def frequency_hash(f, weight: true, proportion: false, percent: false)
            f = f.to_s
            retval = self.inject({}) do |counts, r| 
                k = 1
                k = r[@weight] if @weight && weight
                counts[r[f]] ? counts[r[f]] += k : counts[r[f]] = k
                counts
            end

            if percent || proportion
                total = retval.values.inject(0, :+).to_f
                retval.keys.each do |k|
                    retval[k] /= total
                    retval[k] *= 100 if percent
                end
            end

            retval
        end

        def crosstabulate(rows, columns, weight: true, percent: false)
            t_rows = frequency_hash(rows, weight: false).keys.map(&:to_s)
            t_columns = frequency_hash(columns, weight: false).keys.map(&:to_s)

            retval = RbStatPack::Crosstab.new(t_rows, t_columns)

            self.each do |record|
                k = 1
                k = record[@weight] if @weight && weight
                retval.add(record[rows.to_s].to_s, record[columns.to_s].to_s, k)
            end

            retval
        end
    end
end