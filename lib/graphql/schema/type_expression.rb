# frozen_string_literal: true
module GraphQL
  class Schema
    # @api private
    module TypeExpression
      # Fetch a type from a type map by its AST specification.
      # Return `nil` if not found.
      # @param types [#fetch] A thing for looking up types by name
      # @param ast_node [GraphQL::Language::Nodes::AbstractNode]
      # @return [Class, GraphQL::Schema::NonNull, GraphQL::Schema:List]
      def self.build_type(type_owner, ast_node)
        case ast_node
        when GraphQL::Language::Nodes::TypeName
          type_owner.get_type(ast_node.name)
        when GraphQL::Language::Nodes::NonNullType
          ast_inner_type = ast_node.of_type
          inner_type = build_type(types, ast_inner_type)
          wrap_type(inner_type, :to_non_null_type)
        when GraphQL::Language::Nodes::ListType
          ast_inner_type = ast_node.of_type
          inner_type = build_type(types, ast_inner_type)
          wrap_type(inner_type, :to_list_type)
        else
          raise "Invariant: unexpected type from ast: #{ast_node.inspect}"
        end
      end

      class << self
        private

        def wrap_type(type, wrapper_method)
          if type.nil?
            nil
          elsif wrapper_method == :to_list_type || wrapper_method == :to_non_null_type
            type.public_send(wrapper_method)
          else
            raise ArgumentError, "Unexpected wrapper method: #{wrapper_method.inspect}"
          end
        end
      end
    end
  end
end
