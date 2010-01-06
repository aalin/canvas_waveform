require 'lib/waveform_generator'

if ARGV.empty?
  puts "No filename given"
  exit 1
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
