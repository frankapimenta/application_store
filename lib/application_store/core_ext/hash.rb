class Hash
  # TODO: try to put it working with the Hash refinement.
  def method_missing(m, *args, &blk)
    fetch(m) { fetch(m.to_sym) { super } }
  end
end
