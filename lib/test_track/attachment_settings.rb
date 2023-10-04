module TestTrack
  class AttachmentSettings
    include Singleton

    class << self
      delegate :storage_settings, :max_size, :attachments_enabled?, to: :instance
    end

    def attachments_enabled?
      s3_enabled? || local_enabled?
    end

    def storage_settings
      if s3_enabled?
        s3_settings
      else
        local_settings
      end
    end

    def max_size
      ENV['ATTACHMENT_MAX_SIZE'] || 512.kilobytes
    end

    private

    def s3_enabled?
      unless instance_variable_defined?(:@s3_enabled)
        if storage_strategy == 's3' && !s3_settings_valid?
          Rails.logger.error 'AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and S3_ATTACHMENT_BUCKET are required for S3 storage.'
        end

        @s3_enabled = storage_strategy == 's3' && s3_settings_valid?
      end

      @s3_enabled
    end

    def local_enabled?
      storage_strategy == 'local'
    end

    def local_settings
      {
        storage: :filesystem,
        path: ENV['LOCAL_UPLOAD_PATH'] || ':rails_root/public/system/:class/:attachment/:id_partition/:style/:filename'
      }
    end

    def s3_settings
      {
        storage: :s3,
        s3_credentials: {
          access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID', nil),
          secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY', nil)
        },
        bucket: ENV.fetch('S3_ATTACHMENT_BUCKET', nil),
        s3_region: ENV['AWS_REGION'] || 'us-east-1',
        s3_permissions: ENV['S3_ATTACHMENT_PERMISSIONS'] || 'private',
        path: ENV['S3_ATTACHMENT_PATH'] || ':class/:attachment/:id_partition/:style/:filename'
      }
    end
    # rubocop:enable Metrics/MethodLength

    def s3_settings_valid?
      ENV['AWS_ACCESS_KEY_ID'].present? && ENV['AWS_SECRET_ACCESS_KEY'].present? && ENV['S3_ATTACHMENT_BUCKET'].present?
    end

    def storage_strategy
      if Rails.env.test?
        'local'
      else
        ENV.fetch('ATTACHMENT_STORAGE', nil)
      end
    end
  end
end
