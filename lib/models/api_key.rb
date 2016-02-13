class ApiKey < ActiveRecord::Base

  def claim!
    assert_unclaimed
    update_attribute(:claimed, true)
  end

  def release!
    update_attribute(:claimed, false)
  end

  def available?
    !claimed?
  end

  scope :claimed, -> { where(claimed: true) }
  scope :available, -> { where(claimed: false) }

  private

  def assert_unclaimed
    if claimed?
      raise StandardError, ERR_CLAIMED
    end
  end

  ERR_CLAIMED = <<-EOE
    Key #{self} has already been claimed.
  EOE

end
