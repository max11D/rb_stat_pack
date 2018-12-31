module RbStatPack
    class Crosstab
        include Enumerable

        @matrix = nil
        @orders = nil
        @percentage = nil

        def initialize(row_order, column_order, percentage: false)
            @percentage = !!percentage

            @orders = [row_order.dup, column_order.dup]

            row_count = row_order.is_a?(Array) ? row_order.count : row_order.to_i
            column_count = column_order.is_a?(Array) ? column_order.count : column_order.to_i

            @matrix = []

            row_count.times { @matrix << [] } 
            @matrix.each do |row|
                column_count.times { row << 0 }
            end
        end

        def dup
            retval = Crosstab.new(@orders.first.dup, @orders.last.dup, percentage: @percentage)

            row_count.times do |i|
                column_count.times do |j|
                    retval.set(i, j, @matrix[i][j], indices: true)
                end
            end

            retval
        end

        def add(_i, _j, v)
            _i = _i.to_s
            _j = _j.to_s
            i, j = lookup_orders(_i, _j)

            if i.nil? || j.nil? || v.nil?
                puts self.inspect
                puts _i.inspect, _j.inspect
                puts i.inspect, j.inspect, v.inspect
                binding.pry
            end
            @matrix[i][j] += v
        end

        def get(i, j, indices: false)
            i, j = lookup_orders(i, j) unless indices
            @matrix[i][j]
        end

        def set(i, j, v, indices: false)
            i, j = lookup_orders(i, j) unless indices
            @matrix[i][j] = v
        end

        def subtract(i, j, v, indices: false)
            add(i, j, -v, indices: indices)
        end

        def multiply(i, j, v, indices: false)
            i, j = lookup_orders(i, j) unless indices
            @matrix[i][j] *= v
        end

        def divide(i, j, v, indices: false)
            i, j = lookup_orders(i, j) unless indices
            @matrix[i][j] /= v
        end

        def lookup_orders(i, j)
            i = @orders.first.index(i) unless @orders.first.is_a?(Numeric)
            j = @orders.last.index(j) unless @orders.last.is_a?(Numeric)

            return i, j
        end
        
        def column_sum(j)
            @matrix.inject(0) { |sum, row| sum + row[j] }
        end

        def row_sum(i)
            @matrix[i].inject(0, :+)
        end

        def row_count
            @orders.first.is_a?(Array) ? @orders.first.count : @orders.first
        end

        def column_count
            @orders.last.is_a?(Array) ? @orders.last.count : @orders.last
        end

        def column_sums
            cc = column_count
            rc = row_count
            
            retval = Array.new(cc, 0)
            
            rc.times do |i|
                cc.times do |j|
                    retval[j] += @matrix[i][j]
                end
            end

            retval
        end

        def row_sums
            cc = column_count
            rc = row_count
            retval = Array.new(rc, 0)

            rc.times do |i|
                cc.times do |j|
                    retval[i] += @matrix[i][j]
                end
            end

            retval
        end

        def map!(&block)
            @matrix.each do |row|
                row.map!(&block)
            end
            self
        end

        def percentage_crosstab(total_direction)
            return nil if @percentage # TODO throw exception?
            return nil if total_direction != :column && total_direction != :row # TODO throw exception

            col = (total_direction == :column)

            retval = Crosstab.new(@orders.first, @orders.last, percentage: true)

            cc = column_count
            rc = row_count

            c = col ? column_sums : row_sums
            
            rc.times do |i|
                cc.times do |j|
                    d = c[col ? j : i]
                    v = (d == 0 ? '-' : @matrix[i][j] * 100.0 / d)
                    retval.set(@orders.first[i], @orders.last[j], v)
                end
            end

            retval
        end
        
        def print_table(decimal_places: 2)
            column_widths = Array.new(column_count + 1, 8)

            if (@orders.first.is_a?(Numeric))
                column_widths[0] = Math.log10(@orders.first).to_i + 2
            else
                column_widths[0] = @orders.first.max {|f| f.length }.length + 1
            end

            retval = []

            headers = nil

            if @orders.last.is_a?(Numeric)
                headers = @orders.last.times.map {|x| x.to_s.rjust(8, " ")}
            else
                headers = @orders.last.map.with_index do |x, i| 
                    x = x.rjust(8, " ")
                    column_widths[i+1] = x.length + 2
                end
            end

            if @orders.last.is_a?(Numeric) 
                hline = column_widths.map.with_index do |w, i|
                    line = ""
                    if i == 0
                        line << "".rjust(w, " ")
                    else
                        line << (i-1).to_s.rjust(w, " ")
                    end
                    line
                end
                retval << hline.join("|")
            else
                hline = column_widths.map.with_index do |w, i|
                    line = ""
                    if i == 0
                        line << "".rjust(w, " ")
                    else
                        line << @orders.last[i-1].rjust(w, " ")
                    end
                    line
                end
                retval << hline.join("|")
            end

            retval << retval.first.gsub(/[^|]/, "-")+"-"

            row_labels = @orders.first
            row_labels = row_labels.times.to_a if row_labels.is_a?(Numeric)

            @matrix.each_with_index do |row, i|
                line = ["#{row_labels[i].to_s.ljust(column_widths.first)}"]
                row.each_with_index do |c, j|
                    line << c.round(decimal_places).to_s.rjust(column_widths[j+1], " ")
                end
                retval << line.join("|")
            end

            retval.join("\n")
        end
    end
end