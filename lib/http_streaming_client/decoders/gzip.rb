require 'zlib'

module HttpStreamingClient

  module Decoders

    class Base

      def initialize(&chunk_callback)
	@chunk_callback = chunk_callback
      end

      def <<(compressed)
	return unless compressed && compressed.size > 0
	decompressed = decompress(compressed)
	receive_decompressed decompressed
      end

      def finalize!
	decompressed = finalize
	receive_decompressed decompressed
      end

      private

      def receive_decompressed(decompressed)
	if decompressed && decompressed.size > 0
	  @chunk_callback.call(decompressed)
	end
      end

      protected

      # Must return a part of decompressed
      def decompress(compressed)
	nil
      end

      # May return last part
      def finalize
	nil
      end
    end

    class GZip < Base

      def decompress(compressed)
	@buf ||= StringIO.new
	@buf << compressed

	# Zlib::GzipReader loads input in 2kbyte chunks
	if @buf.size > 2048
	  @gzip ||= Zlib::GzipReader.new @buf
	  @gzip.readline
	end
      end

      def finalize
	begin
	  @gzip ||= Zlib::GzipReader.new @buf
	  @gzip.read
	rescue Zlib::Error
	  raise DecoderError
	end
      end

      class StringIO
	def initialize(string="")
	  @stream = string
	end

	def <<(string)
	  @stream << string
	end

	def read(length=nil, buffer=nil)
	  buffer ||= ""
	  length ||= 0
	  buffer << @stream[0..(length-1)]
	  @stream = @stream[length..-1]
	  buffer
	end

	def size
	  @stream.size
	end
      end
    end

  end

end
