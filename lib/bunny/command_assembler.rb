require "bunny/exceptions"

module Bunny
  class CommandAssembler
    PAYLOAD_SLICE = (0..-2).freeze

    def read_frame(io)
      header = io.read(7)
      type, channel, size = AMQ::Protocol::Frame.decode_header(header)
      data = io.read_fully(size + 1)
      payload, frame_end = data[PAYLOAD_SLICE], data[-1, 1]

      # 1) the size is miscalculated
      if payload.bytesize != size
        raise BadLengthError.new(size, payload.bytesize)
      end

      # 2) the size is OK, but the string doesn't end with FINAL_OCTET
      raise NoFinalOctetError.new if frame_end != AMQ::Protocol::Frame::FINAL_OCTET
      AMQ::Protocol::Frame.new(type, payload, channel)
    end
  end
end
