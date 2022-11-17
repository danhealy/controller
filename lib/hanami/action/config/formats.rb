# frozen_string_literal: true

require "hanami/utils/kernel"

module Hanami
  class Action
    class Config
      # Action format configuration.
      #
      # @since 2.0.0
      # @api private
      class Formats
        # Default MIME type to format mapping
        #
        # @since 2.0.0
        # @api private
        DEFAULT_MAPPING = {
          "application/octet-stream" => :all,
          "*/*" => :all
        }.freeze

        # @since 2.0.0
        # @api private
        attr_reader :mapping

        # @since 2.0.0
        # @api private
        attr_accessor :values

        # @since 2.0.0
        # @api private
        def initialize(values: [], mapping: DEFAULT_MAPPING.dup)
          @values = values
          @mapping = mapping
        end

        # @since 2.0.0
        # @api private
        private def initialize_copy(original) # rubocop:disable Style/AccessModifierDeclarations
          super
          @values = original.values.dup
          @mapping = original.mapping.dup
        end

        # @since 2.0.0
        # @api private
        def mapping=(mappings)
          @mapping = {}

          mappings.each do |format_name, mime_type|
            add(format_name, mime_type)
          end
        end

        # Add a custom format to MIME type mapping and enables the format.
        #
        # @overload add(format, mime_type)
        #   Adds a format mapping to a single MIME type.
        #
        #   @param format [Symbol]
        #   @param mime_type [String]
        #
        #   @example
        #     config.formats.add(:json, "application/json")
        #
        # @overload add(format, mime_types)
        #   Adds a format mapping to multiple MIME types.
        #
        #   @param format [Symbol]
        #   @param mime_types [Array<String>]
        #
        #   @example
        #     config.formats.add(:json, ["application/json+scim", "application/json"])
        #
        # @return [self]
        #
        # @since 2.0.0
        # @api public
        def add(format, mime_types)
          format = Utils::Kernel.Symbol(format)

          Array(mime_types).each do |mime_type|
            @mapping[Utils::Kernel.String(mime_type)] = format
          end

          @values << format unless @values.include?(format)

          self
        end

        # @since 2.0.0
        # @api private
        def empty?
          @values.empty?
        end

        # @since 2.0.0
        # @api private
        def any?
          @values.any?
        end

        # @since 2.0.0
        # @api private
        def map(&blk)
          @values.map(&blk)
        end

        # Clears any previously added mappings and format values.
        #
        # @return [self]
        #
        # @since 2.0.0
        # @api public
        def clear
          @mapping = DEFAULT_MAPPING.dup
          @values = []

          self
        end

        # Retrieve the format name associated with the given MIME Type
        #
        # @param mime_type [String] the MIME Type
        #
        # @return [Symbol,NilClass] the associated format name, if any
        #
        # @example
        #   @config.formats.format_for("application/json") # => :json
        #
        # @see #mime_type_for
        #
        # @since 2.0.0
        # @api public
        def format_for(mime_type)
          @mapping[mime_type]
        end

        # Retrieve the MIME Type associated with the given format name
        #
        # @param format [Symbol] the format name
        #
        # @return [String, nil] the associated MIME Type, if any
        #
        # @example
        #   @config.formats.mime_type_for(:json) # => "application/json"
        #
        # @see #format_for
        #
        # @since 2.0.0
        # @api public
        def mime_type_for(format)
          @mapping.key(format)
        end

        # Returns the default format name
        #
        # @return [Symbol, nil] the default format name, if any
        #
        # @example
        #   @config.formats.default # => :json
        #
        # @since 2.0.0
        # @api public
        def default
          @values.first
        end

        # @since 2.0.0
        # @api private
        def keys
          @mapping.keys
        end
      end
    end
  end
end
