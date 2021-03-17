# frozen_string_literal: true

require_relative '../lib/aspace_messenger.rb'
ArchivesSpaceService.loaded_hook do
  ASpaceMessenger.startup('backend')
end
