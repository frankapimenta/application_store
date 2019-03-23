module ApplicationStore
  module Parenthood
    def parent
      @parent
    end
    def parent= parent
      # if not StoreComposite do not set parent
      # so no need for store composite because store are already composites when they can be parent or child
      parent.add self unless parent.nil? # if not StoreComposite will just skip due to #method_missing
      @parent = parent
    end
  end
end
