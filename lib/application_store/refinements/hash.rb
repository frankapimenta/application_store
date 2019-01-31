module ApplicationStore
  module Refinements
    refine Hash do
      def traverse(&block)
        inject({}) do |h,(k,v)|
          if Hash === v
            v = v.traverse(&block)
          elsif v.respond_to?(:to_hash)
            v = v.to_hash.traverse(&block)
          end
          nk, nv = block.call(k,v)
          h[nk] = nv
          h
        end
      end
    end
  end
end
