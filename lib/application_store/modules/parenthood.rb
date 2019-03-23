module ApplicationStore
  module Parenthood
    def parent
      @parent
    end
    def parent= parent
      parent.add self unless parent.nil? # if not StoreComposite will just skip due to #method_missing
      @parent = parent
    end
  end
end
