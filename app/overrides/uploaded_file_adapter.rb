module Paperclip
  class UploadedFileAdapter < AbstractAdapter
    def initialize(target, option = {})
      @target = target
      cache_current_values
      if @target.respond_to?(:tempfile)
        @tempfile = copy_to_tempfile(@target.tempfile)
      else
        @tempfile = copy_to_tempfile(@target)
      end
    end

    class << self
      attr_accessor :content_type_detector
    end

    private

    def cache_current_values
      self.original_filename = @target.original_filename
      @content_type = determine_content_type
      @size = 0
    end

    def content_type_detector
      self.class.content_type_detector || Paperclip::ContentTypeDetector
    end

    def determine_content_type
      @target.content_type.to_s.strip
    end
  end
end

Paperclip.io_adapters.register Paperclip::UploadedFileAdapter do |target|
  target.class.name.include?("UploadedFile")
end
