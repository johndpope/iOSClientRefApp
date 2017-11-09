
module Fastlane
    module Actions
        
        module SharedValues
            ##COMMIT_CARTHAGE_DEPENDENCIES_CUSTOM_VALUE = :COMMIT_CARTHAGE_DEPENDENCIES_CUSTOM_VALUE
        end
        
        class UpdateAppiconAction < Action
            def self.run(params)
                #require 'xcodeproj'
                require 'pathname'
                require 'set'
                require 'shellwords'
            
                # find the repo root path
                repo_path = Actions.sh('git rev-parse --show-toplevel').strip
                repo_pathname = Pathname.new(repo_path)
            
                # get the list of files that have actually changed in our git workdir
                git_dirty_files = Actions.sh('git diff --name-only HEAD').split("\n") + Actions.sh('git ls-files --other --exclude-standard').split("\n")
                
                icon_files = "iOSReferenceApp/Assets.xcassets"
                
                asset_files_changed = git_dirty_files.select { |i| i.start_with?(icon_files) }
                
                valid_changed_files = asset_files_changed
                
                UI.success("changes #{valid_changed_files}")
                changed_files_as_expected = (Set.new(git_dirty_files.map(&:downcase)) == Set.new(valid_changed_files.map(&:downcase)))
                unless changed_files_as_expected
                    unexpected_files_changed = Set.new(git_dirty_files.map(&:downcase)) - Set.new(valid_changed_files.map(&:downcase))
                    
                    error = [
                        "Found unexpected uncommited changes in the working directory.",
                        "The following files not related to App Icons:",
                        "#{unexpected_files_changed.to_a.join("\n")}",
                        "Make sure you have a clean working directory",
                    ].join("\n")
                    UI.user_error!(error)
                    UI.error(error)
                end
        
                # make sure we have valid changes before we run git commands
                unless valid_changed_files.empty?
                    # get the absolute paths to the files
                    git_add_paths = valid_changed_files.map do |path|
                    updated = path.gsub("$(SRCROOT)", ".").gsub("${SRCROOT}", ".")
                    File.expand_path(File.join(repo_pathname, updated))
                end
    
                UI.success("valid_changed_files")
                # then create a commit with a message
                Actions.sh("git add #{git_add_paths.map(&:shellescape).join(' ')}")
                
                begin
                    # TODO: Find version + build number for each submodule and include that in the commit message
                    module_names = submodule_changes.map{|x| x.gsub(submodule_directory,"")}.join(" ")
                    message = "AppIcon updated"
                    
                    Actions.sh("git commit -m '#{message}'")
                    
                    UI.success("Committed \"#{message}\" 💾.")
                    rescue => ex
                        UI.error(ex)
                        UI.important("Didn't commit any changes.")
                    end
                end
            end
        
            #####################################################
            # @!group Documentation
            #####################################################
            
            def self.description
                "A short description with <= 80 characters of what this action does"
            end
        
            def self.details
                # Optional:
                # this is your chance to provide a more detailed description of this action
                "You can use this action to do cool things..."
            end

            def self.available_options
                [
                #           # Define all options your action supports.
                #                                   end),
                # FastlaneCore::ConfigItem.new(key: :development,
                #                                        env_name: "FL_COMMIT_CARTHAGE_DEPENDENCIES_DEVELOPMENT",
                #                                        description: "Create a development certificate instead of a distribution one",
                #                                        is_string: false, # true: verifies the input is a string, false: every kind of value
                #                                        default_value: false) # the default value if the user didn't provide one
                ]
            end

            def self.output
                #               # Define the shared values you are going to provide
                #               # Example
                #               [
                #                   ['COMMIT_CARTHAGE_DEPENDENCIES_CUSTOM_VALUE', 'A description of what this value contains']
                #               ]
            end

            def self.return_value
                # If you method provides a return value, you can describe here what it does
            end

            def self.authors
                # So no one will ever forget your contribution to fastlane :) You are awesome btw!
                ["FredrikSjoberg"]
            end

            def self.is_supported?(platform)
                platform == :ios
            end
        end
    end
end
