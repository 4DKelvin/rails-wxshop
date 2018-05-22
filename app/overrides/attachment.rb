# encoding: utf-8

module Paperclip
  # The Attachment class manages the files for a given attachment. It saves
  # when the model saves, deletes when the model is destroyed, and processes
  # the file upon assignment.
  class Attachment
    # What gets called when you call instance.attachment = File. It clears
    # errors, assigns attributes, and processes the file. It also queues up the
    # previous file for deletion, to be flushed away on #save of its host.  In
    # addition to form uploads, you can also assign another Paperclip
    # attachment:
    #   new_user.avatar = old_user.avatar
    def assign(filename)
      uploaded_file = ActionDispatch::Http::UploadedFile.new(filename: filename, type: 'image/png', head: '', tempfile: '')
      @file = Paperclip.io_adapters.for(uploaded_file)

      ensure_required_accessors!
      ensure_required_validations!
      if @file.assignment?
        clear(*only_process)

        if @file.nil?
          nil
        else
          assign_attributes
          # post_process_file
          # reset_file_if_original_reprocessed
        end
      else
        nil
      end
    end

    def url(style_name = default_style, options = {})
      url_str = "#{Qiniu::DOMAIN}/#{self.filename}"
      url_str += "-#{style_name}" if style_name.present?
      url_str
    end

    def filename
      self.instance.attachment_file_name
    end
  end
end
