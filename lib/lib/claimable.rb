module Claimable

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def claimed
      where(claimed: true)
    end

    def available
      where(claimed: false)
    end
  end

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
