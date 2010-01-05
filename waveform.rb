#!/usr/bin/ruby

if ARGV.empty?
  puts "No filename given"
  exit 1
end

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



js_data = WaveformGenerator.new(ARGV[0]).generate.flatten.map
html = <<EOF
<!doctype html>
<html>
  <head>
    <title>canvastest</title>
    <script type="text/javascript">
    function drawShape()
    {
      var canvas = document.getElementById('waveform');
      if(canvas.getContext)
      {
        var ctx = canvas.getContext('2d');
        js_data = #{ js_data.inspect };

        ctx.fillStyle = '#ddd'
        ctx.fillRect(0, 0, canvas.width, canvas.height);

        colors = ['#036', '#069', '#09c'];

        for(var color_i = 0; color_i < colors.length; color_i++)
        {
          for(var offset = 0; offset < 2; offset++)
          {
            ctx.beginPath();
              ctx.moveTo(0, canvas.height / 2);
              for(var i = offset; i < js_data.length; i += 2)
              {
                ctx.fillStyle = colors[color_i];
                var x = i / js_data.length * canvas.width;
                var y = js_data[i] * canvas.height / 2 * ((colors.length - color_i) / colors.length) +
                  canvas.height / 2;
                ctx.lineTo(x, y);
              }
              ctx.lineTo(canvas.width, canvas.height / 2);
              ctx.fill();
            ctx.closePath();
          }
        }

        ctx.beginPath();
          ctx.lineWidth = 1;
          ctx.strokeStyle = '#fff';
          ctx.moveTo(0, canvas.height / 2);
          ctx.lineTo(canvas.width, canvas.height / 2);
          ctx.stroke();
        ctx.closePath();
      }
      else
        alert("canvas not supported");
    }
    </script>
  </head>
  <body onload="drawShape();">
  <canvas id="waveform" width="1200" height="500"></canvas>
  </body>
</html>
EOF

File.open('waveform.html', 'w') { |f| f.puts(html) }
