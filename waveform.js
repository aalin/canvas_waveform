function drawWaveform(canvas, waveform_data)
{
  var canvas = document.getElementById('waveform');
  if(canvas.getContext)
  {
    var ctx = canvas.getContext('2d');

    ctx.fillStyle = '#ddd'
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    colors = ['#036', '#069', '#09c'];

    for(var color_i = 0; color_i < colors.length; color_i++)
    {
      for(var offset = 0; offset < 2; offset++)
      {
        ctx.beginPath();
          ctx.moveTo(0, canvas.height / 2);
          for(var i = offset; i < waveform_data.length; i += 2)
          {
            ctx.fillStyle = colors[color_i];
            var x = i / waveform_data.length * canvas.width;
            var y = waveform_data[i] * canvas.height / 2 * ((colors.length - color_i) / colors.length) +
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

musicPlayer = function(audio_object, canvas, waveform_data)
{
  var drawWaveform = function(canvas, ctx) {
    ctx.fillStyle = '#ddd'
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    var colors = ['#600', '#900', '#c60', '#eb0'];

    colors.forEach(function(color, color_i) {
      for(var offset = 0; offset < 2; offset++) {
        ctx.beginPath();
        ctx.moveTo(0, canvas.height / 2);
        for(var i = offset; i < waveform_data.length; i += 2) {
          ctx.fillStyle = color;
          var x = i / waveform_data.length * canvas.width;
          var y = waveform_data[i] * canvas.height / 2 *
            (1 - color_i / colors.length) +
            canvas.height / 2;
          ctx.lineTo(x, y);
        }
        ctx.lineTo(canvas.width, canvas.height / 2);
        ctx.fill();
        ctx.closePath();
      }
    });

    ctx.beginPath();
    ctx.lineWidth = 1;
    ctx.strokeStyle = '#fff';
    ctx.moveTo(0, canvas.height / 2);
    ctx.lineTo(canvas.width, canvas.height / 2);
    ctx.stroke();
    ctx.closePath();
  }

  var drawPositionBar = function(canvas, ctx) {
    ctx.beginPath();
    ctx.lineWidth = 1;
    ctx.strokeStyle = "#000";
    var x = audio_object.currentTime / audio_object.duration * canvas.width;
    ctx.moveTo(x, 0);
    ctx.lineTo(x, canvas.height);
    ctx.stroke();
    ctx.closePath();
  }

  var drawPlayButton = function(canvas, ctx) {
    var center_x = canvas.width / 2;
    var center_y = canvas.height / 2;
		var radius = canvas.height / 2 * 0.9;

    ctx.fillStyle = 'rgba(0, 0, 0, 0.1)';
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    ctx.beginPath();
    ctx.fillStyle = 'rgba(0, 0, 0, 0.5)';
    ctx.arc(center_x, center_y, radius, 0, Math.PI * 2, true);
    ctx.fill();
    ctx.closePath();

		ctx.beginPath();
		ctx.fillStyle = '#fff';
		ctx.strokeStyle = '#fff';
		ctx.moveTo(center_x - Math.cos(45 * Math.PI / 180) * radius * 0.8, center_y - Math.sin(45 * Math.PI / 180) * radius * 0.8);
		ctx.lineTo(center_x - Math.cos(180 * Math.PI / 180) * radius * 0.8, center_y - Math.sin(180 * Math.PI / 180) * radius * 0.8);
		ctx.lineTo(center_x - Math.cos(-45 * Math.PI / 180) * radius * 0.8, center_y - Math.sin(-45 * Math.PI / 180) * radius * 0.8);
		ctx.fill();
		ctx.closePath();
  }

  var draw = function()
  {
    if(canvas.getContext)
    {
      var ctx = canvas.getContext('2d');
      drawWaveform(canvas, ctx);
      drawPositionBar(canvas, ctx);
      if(!isPlaying)
        drawPlayButton(canvas, ctx);
    }
  }

  var isPlaying = false;

  var onClick = function(event) {
    if(isPlaying)
			audio_object.pause();
    else
      audio_object.play();
  }

  var onCanPlay = function() { }
  var onPlay = function() { isPlaying = true; }
  var onPause = function() { isPlaying = false; }
  var onUpdate = function() {
    draw();
  }

  audio_object.addEventListener("canplay", onCanPlay, false);
  audio_object.addEventListener("play", onPlay, false);
  audio_object.addEventListener("pause", onPause, false);
  audio_object.addEventListener("timeupdate", onUpdate, false);
  canvas.addEventListener("click", onClick, false);

  draw();
}
