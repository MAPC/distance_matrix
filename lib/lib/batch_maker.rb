# Implicit yield using Proc.new from
# http://mudge.name/2011/01/26/passing-blocks-in-ruby-without-block.html

class BatchMaker

  def initialize(origin_id: )
    @origin_id = origin_id
  end

  def in_batches(of: 100)
    @of = of.to_i
    raise ProductTooLargeError if @of > 100
    modes.each do |mode|
      loop_over(mode: mode, &Proc.new)
    end
  end

  private

  def loop_over(mode: )
    mode_scope = scope.where(travel_mode: mode)
    count = mode_scope.count
    loop do
      break if count == 0
      mode_scope.find_in_batches(batch_size: @of) do |group|
        count -= group.count
        yield group, mode
      end
    end
  end

  def scope
    TravelTime.where(input_id: @origin_id).where(time: nil)
  end

  def modes
    [:transit, :walking]
    # Get distinct modes from the database and memoize them.
    # @modes ||= TravelTime.select(:travel_mode).distinct.map { |m|
    #   m.travel_mode.to_sym
    # }
  end

end
