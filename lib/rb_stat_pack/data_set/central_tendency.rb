module RbStatPack
    class DataSet
        module CentralTendency
            def range(f)
                x = nil
                n = nil

                self.each { |r| n = r[f] if r[f] < n || n.nil? }
                self.each { |r| x = r[f] if r[f] > x || x.nil? }

                x - n
            end

            def median(f) # todo apply weights
                arr = self.map { |r| r[f] }.sort!
                if arr.length % 2 == 0
                    l = arr.length / 2;
                    if arr[0].is_a?(Numeric)
                        return (arr[l] + arr[l+1]) / 2.0
                    else
                        return arr[l]
                    end
                else
                    return arr[arr.length / 2 + 1]
                end
            end

            def mean(f, weight: true)
                if weight
                    return self.inject(0) { |sum, r| puts r; sum + wget(r, f) } / count().to_f
                else
                    return self.inject(0) { |sum, r| sum + r[f] } / self.count.to_f
                end
            end

            def standard_deviation(f, weight: true)
                Math.sqrt(variance(f, weight: weight))
            end

            def variance(f, weight: true)
                if weight && @weight
                    self.inject(0) { |sum, r| sum + r[@weight] * r[f] * r[f] } / (count - 1)
                else
                    self.inject(0) { |sum, r| sum + r[f] * r[f] } / (count - 1)
                end
            end

            def geometric_mean(f, weight: true)
                if weight && @weight
                    return Math.sqrt(self.inject(1) { |product, r| product * r[f] ** r[@weight] })    
                else
                    return Math.sqrt(self.inject(1) { |product, r| product * r[f] })
                end
            end

            def harmonic_mean(f, weight: true)
                d = self.inject(0) do |sum, r| 
                    w = (@weight && weight) ? r[@weight] : 1
                    sum + w / r[f] 
                end
            end

            def mode(f, weight: true)
                counts = self.frequency_hash(f, weight: weight)
                x = [nil, 0]

                counts.each do |(k,v)| 
                    x = [k,v] if v > x[1] 
                end
                x[0]
            end
        end
    end
end