# config/initializers/active_storage_rewindable_patch.rb
# frozen_string_literal: true

require 'stringio'

module ActiveStorageBlobRewindablePatch
  def build_after_unfurling(*args, **options)
    ensure_rewindable_io(args, options)
    super(*args, **options)
  end

  def build_after_upload(*args, **options)
    ensure_rewindable_io(args, options)
    super(*args, **options)
  end

  def create_after_unfurling!(*args, **options)
    ensure_rewindable_io(args, options)
    super(*args, **options)
  end

  def create_after_upload!(*args, **options)
    ensure_rewindable_io(args, options)
    super(*args, **options)
  end

  def create_and_upload!(*args, **options)
    ensure_rewindable_io(args, options)
    super(*args, **options)
  end

  private

  def ensure_rewindable_io(args, options)
    # Handle keyword arguments (Ruby 3+)
    if options.key?(:io) && options[:io].present?
      io = options[:io]
      if !io.respond_to?(:rewind)
        content = io.respond_to?(:read) ? io.read : io.to_s
        content = content.encode('ISO-8859-1') rescue content.b
        options[:io] = StringIO.new(content)
      end
    end

    # Handle positional hash arguments (Ruby 2.7 / legacy delegation)
    if args.first.is_a?(Hash) && args.first.key?(:io) && args.first[:io].present?
      io = args.first[:io]
      if !io.respond_to?(:rewind)
        content = io.respond_to?(:read) ? io.read : io.to_s
        content = content.encode('ISO-8859-1') rescue content.b
        args.first[:io] = StringIO.new(content)
      end
    end
  end
end

module ActiveStorageBlobInstanceRewindablePatch
  def upload(io, identify: true)
    super(ensure_rewindable(io), identify: identify)
  end

  def unfurl(io, identify: true)
    super(ensure_rewindable(io), identify: identify)
  end

  def upload_without_unfurling(io)
    super(ensure_rewindable(io))
  end

  private

  def ensure_rewindable(io)
    if io.present? && !io.respond_to?(:rewind)
      content = io.respond_to?(:read) ? io.read : io.to_s
      content = content.encode('ISO-8859-1') rescue content.b
      StringIO.new(content)
    else
      io
    end
  end
end

ActiveSupport.on_load(:active_storage_blob) do
  ActiveStorage::Blob.singleton_class.prepend(ActiveStorageBlobRewindablePatch)
  ActiveStorage::Blob.prepend(ActiveStorageBlobInstanceRewindablePatch)
end
