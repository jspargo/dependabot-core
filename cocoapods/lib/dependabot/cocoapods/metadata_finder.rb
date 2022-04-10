# frozen_string_literal: true

require "excon"
require "dependabot/metadata_finders/base"
require "dependabot/shared_helpers"

module Dependabot
  module CocoaPods
    class MetadataFinder < Dependabot::MetadataFinders::Base
      GITHUB_LINK_REGEX = /class="github-link".*?#{Source::SOURCE_REGEX}">/m.
                          freeze

      private

      def look_up_source
        captures = cocoapods_listing.match(GITHUB_LINK_REGEX)&.named_captures
        return if captures.nil?

        Source.from_url("https://github.com/#{captures['repo']}")
      end

      def cocoapods_listing
        return @cocoapods_listing unless @cocoapods_listing.nil?

        # CocoaPods doesn't have a JSON API, so we get the inline HTML from
        # their site... :(
        url = "https://cocoapods.org/pods/#{dependency.name}/inline"
        response = Excon.get(url, middlewares: SharedHelpers.excon_middleware)

        @cocoapods_listing = response.body
      end
    end
  end
end

Dependabot::MetadataFinders.
  register("cocoapods", Dependabot::CocoaPods::MetadataFinder)
