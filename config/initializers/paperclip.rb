require 'test_track/attachment_settings'

Paperclip::Attachment.default_options.merge! TestTrack::AttachmentSettings.storage_settings
