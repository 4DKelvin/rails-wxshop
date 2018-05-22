require 'active_support/core_ext/module/delegation'

module Paperclip
  class AbstractAdapter
    OS_RESTRICTED_CHARACTERS = %r{[/:]}

    attr_reader :content_type, :original_filename, :size
    delegate :binmode, :binmode?, :close, :close!, :closed?, :eof?, :path, :readbyte, :rewind, :unlink, :to => :@tempfile
    alias :length :size

    private

    def copy_to_tempfile(src)
      destination
    end
  end
end
