require 'lib/waveform_generator'

filename = ARGV[0]
outfile = ARGV[1] || 'waveform.html'

unless filename
  puts "Filename not given"
  exit 1
end

waveform_data = WaveformGenerator.new(filename).generate.flatten

require 'enumerator'
js_waveform_data = waveform_data.map { |f|
  format("%.2f", f) # We dont need higher precision
}.each_slice(20).map { |a|
  a.join(",") # Join each slice.
}.join(",\n") # Join everything.

html = <<EOF
<!doctype html>
<html>
  <head>
    <title>canvastest</title>
    <script type="text/javascript" src="waveform.js"></script>
    <script type="text/javascript">
      function setupStuff()
      {
        drawWaveform(document.getElementById('waveform'), [
 #{ js_waveform_data }
]);
      }
    </script>
  </head>
  <body onload="setupStuff();">
    <canvas id="waveform" width="1200" height="500"></canvas>
  </body>
</html>
EOF

File.open(outfile, 'w') { |f| f.puts(html) }
