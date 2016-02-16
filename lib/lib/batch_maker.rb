class BatchMaker

  def intialize(origin_id: )
    @origin_id = origin_id
  end

  def in_batches(of: 100)
    raise ProductTooLargeError if of.to_i > 100
    loop do
      break if scope.count == 0
      current_mode = scope.first.mode
      scope.find_in_batches(batch_size: of.to_i) do |group|
        yield(group, current_mode)
      end
    end
  end

  def scope
    base_scope.where(travel_mode: mode)
  end

  def mode
    # Get the mode of the first record, and use that for everything that follows.
    base_scope.first.mode
  end

  def base_scope
    TravelTime.where(target_id: @origin_id).
               where.not(time: nil)
  end


end
