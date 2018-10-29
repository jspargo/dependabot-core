# frozen_string_literal: true

require "cocoapods-core"
require "dependabot/dependency"
require "dependabot/file_parsers/base"

module Dependabot
  module FileParsers
    module Cocoa
      class CocoaPods < Dependabot::FileParsers::Base
        def parse
          podfile_parser.dependencies.map do |dependency|
            # Ignore dependencies with multiple requirements, since they would
            # cause trouble at the gem update step
            next if dependency.requirement.requirements.count > 1

            Dependency.new(
              name: dependency.name,
              version: dependency_version(dependency.name).to_s,
              requirements: [{
                requirement: dependency.requirement.to_s,
                groups: [],
                source: nil,
                file: "Podfile"
              }],
              package_manager: "cocoapods"
            )
          end.reject(&:nil?)
        end

        private

        def check_required_files
          raise "No Podfile!" unless podfile
          raise "No Podfile.lock!" unless lockfile
        end

        def podfile
          @podfile ||= get_original_file("Podfile")
        end

        def lockfile
          @lockfile ||= get_original_file("Podfile.lock")
        end

        def podfile_parser
          Pod::Podfile.from_ruby(nil, podfile.content)
        end

        # Parse the Podfile.lock to get the pod version. Better than just
        # relying on the dependency's specified version, which may have had a
        # ~> matcher.
        def dependency_version(dependency_name)
          lockfile_hash = Pod::YAMLHelper.load_string(lockfile.content)
          parsed_lockfile = Pod::Lockfile.new(lockfile_hash)

          Gem::Version.new(parsed_lockfile.version(dependency_name))
        end
      end
    end
  end
end