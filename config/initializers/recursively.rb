# Extensions to the Enumerable mixin.

module Enumerable

  # Returns a new enumerable equal to the result of calling {#recursively!} on
  # each element.
  #
  # @see #recursively!

  def recursively(...)
    dup.recursively!(...)
  end

  # Performs the block on the receiver, and also iterates the receiver, calling
  # this method recursively on every element that also duck-types
  # `recursively!`.
  #
  # @param [true, false] include_other_types If `false`, only iterates those
  #   elements sharing the same class as the receiver.
  # @yield (element) A block used to transform each element.
  # @yieldparam [Enumerable] element The receiver, or a recursive enumerable
  #   element therein.
  # @return [Enumerable] The receiver.

  def recursively!(include_other_types: false, &block)
    instance_eval(&block)
    each do |element|
      element.recursively!(include_other_types: include_other_types, &block) if (include_other_types && element.respond_to?(:recursively!)) || element.kind_of?(self.class)
    end
    return self
  end

  # Returns a new enumerable equal to the result of calling {#prune!}.
  #
  # @see #prune!

  def prune(nil_only: false)
    dup.prune!(nil_only: nil_only)
  end

  # Deletes all nil or empty elements from the receiver.
  #
  # @param [true, false] nil_only If `false`, prunes nil/false/empty values. If
  #   `true`, only prunes nil values.
  # @return [Enumerable] The receiver.

  def prune!(nil_only: false)
    delete_if!(&(nil_only ? :nil? : :blank?))
  end
end

# Extensions to the Hash class.

class Hash

  # Hash-specific implementation of {Enumerable#recursively!} that applies the
  # block to matching values only.
  #
  # @see Enumerable#recursively!

  def recursively!(include_other_types: false, &block)
    instance_eval(&block)
    each do |_, element|
      element.recursively!(include_other_types: include_other_types, &block) if (include_other_types && element.respond_to?(:recursively!)) || element.kind_of?(Hash)
    end
    return self
  end

  # Hash-specific implementation of {Enumerable#prune!} that applies the
  # block to the values only.
  #
  # @see Enumerable#prune!

  def prune!(nil_only: false)
    delete_if { |_k, v| nil_only ? v.nil? : v.blank? }
  end
end
