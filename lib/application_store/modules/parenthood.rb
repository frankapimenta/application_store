module ApplicationStore
  module Parenthood
    def parent
      @parent
    end
    def parent= parent
      parent.add self unless parent.nil?
      @parent = parent
    end
  end
end
