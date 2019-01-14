# frozen_string_literal: true

require "cocoapods-core"

module Dependabot
  module CocoaPods
    class Requirement < Pod::Requirement
      def self.parse(obj)
        Pod::Requirement.new(obj.to_s).requirements.flatten
      end
    end
  end
end
