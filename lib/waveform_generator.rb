class WaveformGenerator
  RESOLUTION = 1000

  class Bucket
    attr_reader :min, :max
    def initialize
      @min = 0
      @max = 0
    end

    def add(x)
      @max = x if x > @max
      @min = x if x < @min
    end

    def peak
      [@min.abs, @max.abs].max
    end
  end

  def initialize(filename)
    @filename = filename
  end

  def generate
    bytes = self.read_pcm
    raise "no pcm data" if bytes.empty?

    width = RESOLUTION

    buckets = Array.new(width) { Bucket.new }
    bucket_size = ((bytes.size - 1).to_f / width.to_f + 0.5).to_i + 1

    bytes.each_with_index do |byte,i|
      buckets[i / bucket_size].add(byte)
    end

    peak = buckets.inject(0) { |peak, bucket| bucket.peak > peak ? bucket.peak : peak } / 65535.0

    buckets.map do |bucket|
      [bucket.min, bucket.max].map { |i| i / 65535.0 / peak }
    end
  end

  def read_pcm
    x = nil
    IO.popen('-') do |io|
      exec('sox', @filename, '-t', 'raw', '-r', '4000', '-c', '1', '-s', '-L', '-') unless io
      x = io.read
    end
    x.unpack("s*")
  end
end

