unit WebAudioAPIHelper;

interface

uses
  System.SysUtils, System.Classes, JS, Web, WEBLib.Modules, WEBLib.Controls, jsdelphisystem;

type
  TWAAH = class(TWebDataModule)
    procedure WebDataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
     tabPlaylist: JSValue;
     tabTracklist: JSValue;
     tabTrackListReady: Boolean;
     AudioCtx: JSValue;
     AudioSrc: JSValue;
     AudioGain: JSValue;
     AudioAnalyser: JSValue;
     AudioStereoPanner: JSValue;
     AudioStart: JSValue;
     AudioRecorder: JSValue;
     AudioBlob: JSValue;
     NextID: Integer;
     TimelineTime: Integer;
     TImelineLength: Integer;
     TimelineOffset: Integer;
     procedure InitializeAudio;
     procedure PlayAudio(Start: Double);
     procedure InitializePlaylist(ElementID: String);
     procedure InitializeTrackList(ElementID: String);
     [async] procedure LoadTrack(TrackName: String; TrackData: TJSArrayBufferRecord);
     [async] procedure LoadAudioTrack(TrackName: String; TrackData: TJSArrayBufferRecord);
     procedure DrawTimeline(PixelsPerSecond: Integer; TimelineSeconds: Integer; TimelineDiv: String);
     procedure RemoveTrack;
     procedure RemoveAudioTrack;
     procedure CloneAudioTrack;
     procedure SavePlaylist;
     procedure SaveProject;
     procedure LoadPlaylist(data: String);
     procedure LoadProject(data: String);
     procedure GetCurrentPosition;
     procedure PauseAudio;
     procedure LoadNextTrack;
     procedure LoadPreviousTrack;
     procedure ShufflePlaylist;
     procedure SetVolume(volume: double);
     procedure DrawVisualizer;
     procedure ResetProject;
     procedure RedrawTracklist;
     procedure SwapEditMode(EditMode: Boolean);
     procedure PlayProject;
     procedure StopProject;
     procedure VolumeChanged(Value: Integer);
     procedure BalanceChanged(Value: Integer);
     function GetCursorPosition:Integer;
     procedure ExportProject;
  end;

var
  WAAH: TWAAH;

implementation

uses Unit1;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TWAAH }

procedure TWAAH.StopProject;
begin

  {$IFNDEF WIN32}
  asm
    var WAAH = pas.WebAudioAPIHelper.WAAH;
    WAAH.AudioRecorder.finishRecording();

    var rows = WAAH.tabTracklist.getRows();
    for (var i = 0; i < rows.length; i++) {
      rows[i].getCell('AUDIOSRC').getValue().disconnect();
      rows[i].getCell('AUDIOGAIN').getValue().disconnect();
      rows[i].getCell('AUDIOPAN').getValue().disconnect();
      rows[i].getCell('AUDIOSRC').setValue(null);
      rows[i].getCell('AUDIOGAIN').getValue(null);
      rows[i].getCell('AUDIOPAN').getValue(null);
    }

  end;
  {$ENDIF}

end;

procedure TWAAH.PlayProject;
begin
  asm
    var WAAH = pas.WebAudioAPIHelper.WAAH;
    var rows = WAAH.tabTracklist.getRows();
    WAAH.AudioStart = WAAH.AudioCtx.currentTime;

    WAAH.AudioRecorder = new WebAudioRecorder(WAAH.AudioAnalyser, {
      workerDir: "js/"
    });

    WAAH.AudioRecorder.setOptions({
      timeLimit: 300,
      encodeAfterRecord: true,
      ogg: {
        quality: 0.5
      },
      mp3: {
        bitRate: 160
      }
    });

    WAAH.AudioRecorder.onComplete = function(recorder, blob) {
      console.log("Encoding complete");
      document.getElementById('btnExport').innerHTML = '<i class="fa-solid fa-bullseye text-success fa-3x"></i>';
      WAAH.AudioBlob = blob;
    }

    WAAH.AudioRecorder.startRecording();
    document.getElementById('btnExport').innerHTML = '<i class="fa-solid fa-bullseye text-danger fa-beat-fade fa-3x"></i>';

    for (var i = 0; i < rows.length; i++) {
      var ABSN = new AudioBufferSourceNode(WAAH.AudioCtx);
      var GAIN = new GainNode(WAAH.AudioCtx);
      var PAN = new StereoPannerNode(WAAH.AudioCtx);

      ABSN.buffer = rows[i].getCell('TRACKBUF').getValue();

      rows[i].getCell('AUDIOSRC').setValue(ABSN);
      rows[i].getCell('AUDIOGAIN').setValue(GAIN);
      rows[i].getCell('AUDIOPAN').setValue(PAN);


//      console.log(rows[i].getCell('TRACKGAIN').getValue());;
//      console.log(rows[i].getCell('TRACKPAN').getValue());;
//      console.log(rows[i].getCell('TRACKPITCH').getValue());;
//      console.log(rows[i].getCell('TRACKSPEED').getValue());;

      const volarray = [0.00, 0.25, 0.50, 0.75, 1.00, 1.25, 1.50, 1.75, 2.00];
      GAIN.gain.value = volarray[rows[i].getCell('TRACKGAIN').getValue() -1];

      const panarray = [-1.00, -0.75, -0.50, -0.25, 0.00, 0.25, 0.50, 0.75, 1.00];
      PAN.pan.value = panarray[rows[i].getCell('TRACKPAN').getValue() -1];

      const detunearray = [-2400, -1800, -1200, -600, 0, 600, 1200, 1800, 2400];
      ABSN.detune.value = detunearray[rows[i].getCell('TRACKPITCH').getValue() -1]

      const ratearray = [0.20, 0.40, 0.60, 0.80, 1.00, 1.20, 1.40, 1.6, 1.80];
      ABSN.playbackRate.value = ratearray[rows[i].getCell('TRACKSPEED').getValue() -1];

      if (rows[i].getCell('MUTE').getValue() == true) {
        GAIN.gain.value = 0;
      }

      if (rows[i].getCell('LOOP').getValue() == true) {
        ABSN.loop = true;
      }

      ABSN.connect(GAIN)
          .connect(PAN)
          .connect(WAAH.AudioGain)
          .connect(WAAH.AudioStereoPanner)
          .connect(WAAH.AudioAnalyser)
          .connect(WAAH.AudioCtx.destination);

      // These are the three default start() values before accounting for track editing
      var playstart = 0;
      var playoffset = 0;
      var playduration = ABSN.buffer.duration;

      var tracklength = parseFloat(rows[i].getCell('WAVEFORM').getElement().firstElementChild.firstElementChild.firstElementChild.getAttribute('width'));
      var trackstart = parseFloat(rows[i].getCell('WAVEFORM').getElement().firstElementChild.firstElementChild.getAttribute('data-x') || 0);
      var tracktl = parseFloat(rows[i].getCell('WAVEFORM').getElement().firstElementChild.firstElementChild.getAttribute('data-tl') || 0);
      var tracktr = parseFloat(rows[i].getCell('WAVEFORM').getElement().firstElementChild.firstElementChild.getAttribute('data-tr') || 0);

      playstart = WAAH.AudioCtx.currentTime + ((trackstart / tracklength) * playduration);
      playoffset = ((tracktl * -1) / tracklength) * playduration;
      playduration = ((tracklength + tracktl - tracktr) / tracklength) * playduration;

//      console.log('dur: '+ABSN.buffer.duration);
//      console.log('tim: '+WAAH.AudioCtx.currentTime);
//      console.log('len: '+tracklength);
//      console.log('str: '+trackstart);
//      console.log('ttl: '+tracktl);
//      console.log('ttr: '+tracktr);
//      console.log('pst: '+playstart);
//      console.log('off: '+playoffset);
//      console.log('dur: '+playduration);

      if (rows[i].getCell('PLAY').getValue() == true) {
        if (ABSN.loop == true) {
          ABSN.start(playstart, playoffset);
        }
        else {
          ABSN.start(playstart, playoffset, playduration);
        }
      }
    }

  end;

end;


procedure TWAAH.BalanceChanged(Value: Integer);
begin
  // Value = range 1..9
  asm
    const panarray = [-1.00, -0.75, -0.50, -0.25, 0.00, 0.25, 0.50, 0.75, 1.00]
    this.AudioStereoPanner.pan.value = panarray[Value-1];
  end;
end;

procedure TWAAH.CloneAudioTrack;
begin
  // Clone selected tracks
  asm
    const WAAH = pas.WebAudioAPIHelper.WAAH;
    var rows = WAAH.tabTracklist.getSelectedRows();
    for (var i = 0; i < rows.length; i++) {

      var TrackID = WAAH.NextID + 1;
      WAAH.NextID = TrackID;

      console.log(TrackID);
      WAAH.tabTracklist.addRow({
        ID: TrackID,
        TRACKNAME: rows[i].getCell('TRACKNAME').getValue(),
        TRACKBUF:  rows[i].getCell('TRACKBUF').getValue(),
        TRACK: rows[i].getCell('TRACK').getValue(),
        ARTIST: rows[i].getCell('ARTIST').getValue(),
        ALBUM: rows[i].getCell('ALBUM').getValue(),
        COVER: rows[i].getCell('COVER').getValue(),
        PLAY: rows[i].getCell('PLAY').getValue(),
        MUTE: rows[i].getCell('MUTE').getValue(),
        LOOP: rows[i].getCell('LOOP').getValue(),
        WAVEFORM: rows[i].getCell('WAVEFORM').getValue(),
        AUDIOSRC: rows[i].getCell('AUDIOSRC').getValue(),
        AUDIOGAIN:rows[i].getCell('AUDIOGAIN').getValue(),
        AUDIOPAN: rows[i].getCell('AUDIOPAN').getValue(),
        TRACKGAIN: rows[i].getCell('TRACKGAIN').getValue(),
        TRACKPAN: rows[i].getCell('TRACKPAN').getValue(),
        TRACKPITCH: rows[i].getCell('TRACKPITCH').getValue(),
        TRACKSPEED: rows[i].getCell('TRACKSPEED').getValue(),
        CONTROLS:'<div class="CusomTrackbar" title="Gain" style="position:absolute; transform:rotate(-20deg); left:5px; width:90px; height:20px; top:21px;">'+
                '  <div class="rounded border border-dark bg-white" style="position:absolute; width:86px; height:10px; top:5px; left:7px;"></div>'+
                '  <div id="track-Vol-'+TrackID+'"'+
                '          class="draggableTrackbar rounded-pill border border-2"'+
                '          style="cursor:nesw-resize; border-color: #000 !important; background-color: #f00; position:absolute; width: 20px; height: 20px; top: 0px; left:0px;transform:translate(40px,0px)"'+
                '          data-x="40">'+
                '  </div></div>'+
                '<div class="CusomTrackbar" title="Pan" style="position:absolute; transform:rotate(-20deg); left:80px; width:90px; height:20px; top:21px;">'+
                '  <div class="rounded border border-dark bg-white" style="position:absolute; width:86px; height:10px; top:5px; left:7px"></div>'+
                '  <div id="track-Pan-'+TrackID+'"'+
                '          class="draggableTrackbar rounded-pill border border-2"'+
                '          style="cursor:nesw-resize; border-color: #000 !important; background-color: #070; position:absolute; width: 20px; height: 20px; top: 0px; left:0px;transform:translate(40px,0px)"'+
                '          data-x="40">'+
                '  </div></div>'+
                '<div class="CusomTrackbar" title="Pitch" style="position:absolute; transform:rotate(-20deg); left:155px; width:90px; height:20px; top:21px;">'+
                '  <div class="rounded border border-dark bg-white" style="position:absolute; width:86px; height:10px; top:5px; left:7px"></div>'+
                '  <div id="track-Dtn-'+TrackID+'"'+
                '          class="draggableTrackbar rounded-pill border border-2"'+
                '          style="cursor:nesw-resize; border-color: #000 !important; background-color: #00f; position:absolute; width: 20px; height: 20px; top: 0px; left:0px;transform:translate(40px,0px)"'+
                '          data-x="40">'+
                '  </div></div>'+
                '<div class="CusomTrackbar" title="Speed" style="position:absolute; transform:rotate(-20deg); left:230px; width:90px; height:20px; top:21px;">'+
                '  <div class="rounded border border-dark bg-white" style="position:absolute; width:86px; height:10px; top:5px; left:7px"></div>'+
                '  <div id="track-Spd-'+TrackID+'"'+
                '          class="draggableTrackbar rounded-pill border border-2"'+
                '          style="cursor:nesw-resize; border-color: #000 !important; background-color: #ff0; position:absolute; width: 20px; height: 20px; top: 0px; left:0px;transform:translate(40px,0px)"'+
                '          data-x="40">'+
                '  </div></div>'
      }, false, rows[i].getCell('ID').getValue())
    }
  end;
end;

procedure TWAAH.DrawTimeline(PixelsPerSecond: Integer; TimelineSeconds: Integer; TimelineDiv: String);
begin
  // First, let's draw a new timeline D3 chart at the top
  asm
    var TimelineElement = '#'+TimelineDiv;
    var TimelineWidth = PixelsPerSecond * TimelineSeconds;
    var TickFrequency = 30;
    switch (PixelsPerSecond) {
      case 9: TickFrequency =   5; break;
      case 8: TickFrequency =   5; break;
      case 7: TickFrequency =  10; break;
      case 6: TickFrequency =  10; break;
      case 5: TickFrequency =  15; break;
      case 4: TickFrequency =  15; break;
      case 3: TickFrequency =  30; break;
      case 2: TickFrequency =  30; break;
      case 1: TickFrequency =  60; break;
    }

    // Delete any prior svg element
    d3.select(TimelineElement)
      .selectAll("svg")
      .remove();

   // Create svg element
    var svg = d3.select(TimelineElement)
                .append("svg")
                .attr("width", TimelineWidth);

    // Create time scale starting at 00:00
    var x = d3.scaleUtc()
              .domain([0, TimelineSeconds * 1000])
              .range([-1, TimelineWidth]);

    // Draw the axis
    svg.append("g")
       .attr("transform", "translate(0,14)")      // This controls the vertical position of the Axis
       .attr("class","axis")
       .call(d3.axisBottom(x)
             .tickSize(-5)
             .tickFormat(d3.timeFormat("%M:%S"))
             .ticks(d3.timeSecond.every(TickFrequency)));

    // Remove the very first tick
    d3.select(".tick").remove();

    // Note: color of axis is set via CSS .axis selector

    // Set column width in Tabulator to match the Timeline
    // Note that this can be called from a Tabulator function callback, so we
    // lose our regular context.
    pas.WebAudioAPIHelper.WAAH.tabTracklist.getColumn('WAVEFORM').setWidth(TimelineWidth);

    // Adjust waveform scale to match timeline
    var rows = this.tabTracklist.getRows();
    for (var i = 0; i < rows.length; i++) {
      rows[i].getCell('WAVEFORM').getElement().firstElementChild.style.transformOrigin = '0px 0px';
      rows[i].getCell('WAVEFORM').getElement().firstElementChild.style.transform = 'scaleX('+TimelineWidth / (5.0 * TimelineSeconds)+')';
    }

    pas.WebAudioAPIHelper.WAAH.TimelineTime = TimelineSeconds;
    pas.WebAudioAPIHelper.WAAH.TimelineLength = TimelineWidth;
    pas.WebAudioAPIHelper.WAAH.TimelineOffset = 0;
  end;
end;

procedure TWAAH.DrawVisualizer;
var
  VisWidth: Integer;
  VisHeight: Integer;
begin
  VisWidth := Form1.divVisualizer.width;
  VisHeight := Form1.divVisualizer.Height;
  asm
    const h = VisHeight;
    const w = VisWidth;

    var colors
    let svg;

    d3.select('#divVisualizer')
      .selectAll("svg")
      .remove();

    svg = d3.select('#divVisualizer').append('svg')
        .attr('width', w)
        .attr('height', h)
        .attr('id', 'visualizer-svg');


    this.AudioAnalyser.fftSize = 1024;
    const dataArray = new Uint8Array(this.AudioAnalyser.frequencyBinCount);

    const colorScale = d3.scaleSequential(d3.interpolateSinebow)
      .domain([1, 255])

    const y = d3.scaleLinear()
      .domain([0, 255])
      .range([h, 0])

    svg.selectAll('rect')
      .data(dataArray)
      .enter().append('rect')
      .attr('width', ((w / dataArray.length) * 0.8))
      .attr('x', function (d, i) { return (((w / dataArray.length) * i) + ((w / dataArray.length) * 0.1)) })

    function renderFrame () {
      requestAnimationFrame(renderFrame)
      pas.WebAudioAPIHelper.WAAH.AudioAnalyser.getByteFrequencyData(dataArray)

      svg.selectAll('rect')
        .data(dataArray)
        .attr('height', function (d) { return (h - y(d)) })
        .attr('y', function (d) { return y(d) })
        .attr('fill', function (d) { return d === 0 ? 'black' : colorScale(d) })
    }
    renderFrame()
  end;
end;

procedure TWAAH.ExportProject;
begin
  asm
    var WAAH = pas.WebAudioAPIHelper.WAAH;
    var streamSaver = window.streamSaver;
    const fileStream = streamSaver.createWriteStream('New Audio.wav', {
      size: WAAH.AudioBlob.size // Makes the procentage visiable in the download
    })
    const readableStream = WAAH.AudioBlob.stream()
    window.writer = fileStream.getWriter()
    const reader = readableStream.getReader()
    const pump = () => reader.read()
      .then(res => res.done
          ? writer.close()
          : writer.write(res.value).then(pump))
    pump()
  end;
end;

procedure TWAAH.GetCurrentPosition;
begin
  asm
    if (this.AudioSrc !== undefined) {
      pas.Unit1.Form1.PlayerNow = this.AudioCtx.currentTime - this.AudioStart;
    }
    else {
      pas.Unit1.Form1.PlayerNow = -1;
      pas.Unit1.Form1.PlayerDuration = -1;
    }
  end;
end;

function TWAAH.GetCursorPosition: Integer;
var
  Elapsed: Double;
  Remaining: Double;
begin
  asm
    var WAAH = pas.WebAudioAPIHelper.WAAH;
    var startpos = 384;
    var playtime = WAAH.AudioCtx.currentTime - WAAH.AudioStart; // seconds
    Result = Math.max(startpos, startpos + ((playtime / WAAH.TimelineTime) * WAAH.TimelineLength) - WAAH.TimelineOffset);

    Elapsed = playtime;
    Remaining = WAAH.TimelineTime - playtime;
  end;

  Form1.divElapsed.Caption := FormatDateTime('hh:nn:ss.zzz', Elapsed / 86400.0);
  Form1.divRemaining.Caption := FormatDateTime('hh:nn:ss.zzz', Remaining / 86400.0);
end;

procedure TWAAH.InitializeAudio;
begin
  asm
    this.AudioCtx = new (window.AudioContext || window.webkitAudioContext)();
    this.AudioGain = new GainNode(this.AudioCtx);
    this.AudioAnalyser = new AnalyserNode(this.AudioCtx);
    this.AudioStereoPanner = new StereoPannerNode(this.AudioCtx);
    this.AudioMediaDestination = new MediaStreamAudioDestinationNode(this.AudioCtx);
  end;
end;

procedure TWAAH.PauseAudio;
begin
  asm
    this.AudioSrc.stop();
  end;
end;

procedure TWAAH.PlayAudio(Start: Double);
begin
  {$IFNDEF WIN32}
  asm
    // might be called from other JS events, so let's fully qualify everything
    var WAAH = pas.WebAudioAPIHelper.WAAH;

    // If playlist is loaded, ArrayBuffers will need to be regenerated
    function base64ToArrayBuffer(base64) {
      var binary_string = window.atob(base64);
      var len = binary_string.length;
      var bytes = new Uint8Array( len );
      for (var i = 0; i < len; i++) {
        bytes[i] = binary_string.charCodeAt(i);
      }
      return bytes.buffer;
    }

    // If it is already playing, then do everything we can to stop it and
    // clear out any data or memory.  Unclear if this is sufficient.
    if (this.AudioSrc !== undefined) {
      try {
        WAAH.AudioSrc.stop();
        WAAH.AudioSrc.disconnect();
        WAAH.AudioSrc.buffer = null;
      }
      finally {
        WAAH.AudioSrc = this.AudioCtx.createBufferSource();
      }
    }
    else {
      WAAH.AudioSrc = this.AudioCtx.createBufferSource();
    }

    // If a row is selected, start playing the first one.
    var rows = WAAH.tabPlaylist.getSelectedRows();
    if (rows.length !== 0) {

      // Figure out what the first selected row in the table is
      var firstrow = 999999;
      var firstindex = 0;
      for (var i = 0; i < rows.length; i++) {
        if (rows[i].getPosition() < firstrow) {
          firstrow = rows[i].getPosition();
          firstindex = i;
        }
      }

      // Set this as the only selected row
      WAAH.tabPlaylist.deselectRow();
      WAAH.tabPlaylist.selectRow(rows[firstindex]);

      // Get the ArrayBuffer from the table if it is there.
      // If it isn't there, convert the BAse64 data into an ArrayBuffer
      var AudioData = new Uint8Array(rows[firstindex].getCell('TRACKBUF').getValue()).buffer;
      if (AudioData == undefined) {
        AudioData = base64ToArrayBuffer(rows[firstindex].getCell('TRACKDATA').getValue());
        rows[0].getCell('TRACKDATABUF').setValue(new Uint8Array(AudioData));
      }

      // Convert ArrayBuffer into audio data the Web Audio API understands
      WAAH.AudioCtx.decodeAudioData(
        AudioData.slice(0),
        (buffer) => {

          WAAH.AudioSrc.buffer = buffer;
          WAAH.AudioSrc.connect(WAAH.AudioGain).connect(WAAH.AudioAnalyser).connect(WAAH.AudioCtx.destination);

          // Kind of resuming a pause here but also good for having the
          // scrubber be able to set the play position.  Not ideal.
          WAAH.AudioSrc.start(0, Start*buffer.duration, (buffer.duration - Start*buffer.duration));

          // We don't have a "position" with AudioBufferSource Node, so
          // we need to keep track of timestamps ourselves.  Boo.
          WAAH.AudioStart = WAAH.AudioCtx.currentTime - (Start*buffer.duration);
          pas.Unit1.Form1.PlayNow = Start*buffer.duration;
          pas.Unit1.Form1.PlayerDuration = buffer.duration;
        },

        // Guess it got some data it didn't understand :(
        (e) => {
          console.log("Error decoding audio data: "+e.error);
        }
      );
    }
  end;
  {$ENDIF}
end;


procedure TWAAH.InitializePlaylist(ElementID: String);
begin
  // This creates the Tabulator instance for the playlist
  asm
    this.tabPlaylist = new Tabulator("#"+ElementID, {
      index: "ID",
//      layout: "fitColumns",
      movableRows: true,
      movableColumns: false,
      selectable: true,
      rowHeight: 50,
      headerVisible: false,
      columns: [
        { title: "ID", field: "ID", width: 50, topCalc: "max", visible: false },
        { title: "Filename", field: "TRACKNAME", visible: false },
        { title: "Filedata", field: "TRACKDATA", visible: false },
        { title: "Filebuf", field: "TRACKBUF", visible: false },
        { title: "Cover Art", field: "COVER", width: 50, cssClass: "NoPadding", resizable: false,
            formatter: "image",
            formatterParams: {width: 50, height:50  }
        },
        { title: "Track Name", field: "TRACK", resizable: false,
            formatter: function(cell, formatterParams, onRendered) {
              var album = cell.getRow().getCell('ALBUM').getValue();
              if ((album !== undefined) && (album !== '')){
                album = ' ['+album+']';
              }
              return '<strong>'+cell.getValue()+'</strong><br />'+cell.getRow().getCell('ARTIST').getValue()+album;
            }
        },
        { title: "Artist Name", field: "ARTIST", visible: false },
        { title: "Album Name", field: "ALBUM", visible: false },
      ]
    });

    this.tabPlaylist.on("rowClick", function(e,row) {
      if (pas.Unit1.Form1.PlayerState == 'Paused') {
        divCover.innerHTML = '<image src='+row.getCell("COVER").getValue()+' width=100% height=100%>'
        console.log(row);
        console.log(row.isSelected());
        row.getTable().deselectRow();
        row.select();
//        if (row.isSelected()) {
//          row.deselect();
//        }
//        else {
//          row.select()
//        }
      }
      else {
        divCover.innerHTML = '<image src='+row.getCell("COVER").getValue()+' width=100% height=100%>'
        row.getTable().deselectRow();
        row.select();
        pas.WebAudioAPIHelper.WAAH.PlayAudio(0);
      }
    });
  end;
end;

procedure TWAAH.InitializeTracklist(ElementID: String);
begin
  // This creates the Tabulator instance for the playlist
  asm
    this.tabTracklist = new Tabulator("#"+ElementID, {
      index: "ID",
      layout: "fitColumns",
      movableRows: true,
      movableColumns: false,
      selectable: true,
      rowHeight: 56,
      headerVisible: false,
      placeholder: "No Tracks Loaded",
      columns: [
        { title: "Cover Art", field: "COVER", width: 56, cssClass: "NoPadding NoInteraction", resizable: false, rowHandle: true, frozen: true,
            formatter: "image",
            formatterParams: {width: 56, height:56 }
        },
        { title: "Track Name", field: "TRACK", resizable: false, width: 245,  frozen: true,
            formatter: function(cell, formatterParams, onRendered) {
              var album = cell.getRow().getCell('ALBUM').getValue();
              if ((album !== undefined) && (album !== '')){
                album = ' ['+album+']';
              }
              return '<div style="font-family:Cairo; white-space:normal;">'+
                       '<span style="color:#fff; font-size:16px; font-weight: 500;">'+cell.getValue()+'</span><br />'+
                       '<span style="color:#aaa;">'+cell.getRow().getCell('ARTIST').getValue()+album+'</span>'+
                     '</div>';
            }
        },
        { title: "Play", field: "PLAY", width: 40, frozen: true, resizable: false,
            formatter: function(cell, formatterParams, onRendered) {
              if (cell.getValue() == true) {
                return '<div class="d-flex h-100 align-items-center justify-content-center"><i class="fa-solid fa-play text-white fa-xl fa-fw"></i></div>'
              }
              else {
                return '<div class="d-flex h-100 align-items-center justify-content-center"><i class="fa-solid fa-pause text-secondary fa-xl fa-fw"></i></div>'
              }
            },
            cellClick: function (e, cell) {
              cell.setValue(!cell.getValue());
              cell.getTable().selectRow(cell.getRow());
            }
        },
        { title: "Loop", field: "LOOP", width: 40, frozen: true, resizable: false,
            formatter: function(cell, formatterParams, onRendered) {
              if (cell.getValue() == true) {
                return '<div class="d-flex h-100 align-items-center justify-content-center"><i class="fa-solid fa-repeat text-white fa-xl fa-fw"></i></div>'
              }
              else {
                return '<div class="d-flex h-100 align-items-center justify-content-center"><i class="fa-solid fa-repeat text-secondary fa-xl fa-fw"></i></div>'
              }
            },
            cellClick: function (e, cell) {
              cell.setValue(!cell.getValue());
              cell.getTable().selectRow(cell.getRow());
            }
        },

        { title: "Waveform", field: "WAVEFORM", resizable: false, formatter: "html",
            cellClick: function (e, cell) {
              cell.getTable().selectRow(cell.getRow());
            }
        },

        { title: "ID", field: "ID", width: 50, topCalc: "max", visible: false },
        { title: "Filename", field: "TRACKNAME", visible: false },
        { title: "Filedata", field: "TRACKDATA", visible: false },
        { title: "Filebuf", field: "TRACKBUF", visible: false },
        { title: "Artist Name", field: "ARTIST", visible: false },
        { title: "Album Name", field: "ALBUM", visible: false },
        { title: "Audio Source Node", field: "AUDIOSRC", visible: false },
        { title: "Audio Gain Node", field: "AUDIOGAIN", visible: false },
        { title: "Audio Pan Node", field: "AUDIOPAN", visible: false },
        { title: "Trackbar Volume", field: "TRACKGAIN", visible: false },
        { title: "Trackbar Balance", field: "TRACKPAN", visible: false },
        { title: "Trackbar Pitch", field: "TRACKPITCH", visible: false },
        { title: "Trackbar Rate", field: "TRACKSPEED", visible: false },



        { title: "Mute", field: "MUTE", width: 40, frozen: true, resizable: false,
            formatter: function(cell, formatterParams, onRendered) {
              if (cell.getValue() == true) {
                return '<div class="d-flex h-100 align-items-center justify-content-center"><i class="fa-solid fa-volume-off text-white fa-xl fa-fw"></i></div>'
              }
              else {
                return '<div class="d-flex h-100 align-items-center justify-content-center"><i class="fa-solid fa-volume-off text-secondary fa-xl fa-fw"></i></div>'
              }
            },
            cellClick: function (e, cell) {
              cell.setValue(!cell.getValue());
              cell.getTable().selectRow(cell.getRow());
              if (cell.getRow().getCell('AUDIOGAIN').getValue() !== null) {
                if (cell.getValue() == true) {
                  cell.getRow().getCell('AUDIOGAIN').getValue().gain.value = 0;
                }
                else {
                  var vol = cell.getRow().getCell('TRACKGAIN').getValue();
                  var volarray = [0.00, 0.25, 0.50, 0.75, 1.00, 1.25, 1.50, 1.75, 2.00];
                  cell.getRow().getCell('AUDIOGAIN').getValue().gain.value = volarray[vol -1];
                }
              }
            }
        },
        { title: "Controls", field: "CONTROLS", width: 340, frozen: true, resizable: false, formatter: "html",
            cellClick: function (e, cell) {
              cell.getTable().selectRow(cell.getRow());
            }
        }
      ]
    });

    this.tabTracklist.on("tableBuilt", function() {
      // Initialize Timeline
      pas.WebAudioAPIHelper.WAAH.DrawTimeline(5, 300, 'divTimelineChart');
      // Table is ready
      pas.WebAudioAPIHelper.WAAH.tabTracklistReady = true;

      const scroller = document.getElementById("divMiddle").lastElementChild;
      const timeline = document.getElementById("divTimelineChart");
      scroller.addEventListener("scroll",  (e) => {
        timeline.style.transform = 'translateX('+(e.target.scrollLeft * -1)+'px)';
        pas.WebAudioAPIHelper.WAAH.TimelineOffset = e.target.scrollLeft;
      });

    });

    this.tabTracklist.on("rowClick", function(e,row) {
//      row.getTable().deselectRow();
//      row.select();
    });
  end;
end;

procedure TWAAH.LoadTrack(TrackName: String; TrackData: TJSArrayBufferRecord);
var
  TrackID: Integer;
begin
  // We've got a track to load.  So let's load it.
  TrackID := NextID + 1;
  {$IFNDEF WIN32}
  asm
    // These are the fields we're looking to populate
    var Track = TrackName;
    var Artist = '';
    var Album = '';
    var Cover = 'images/missingartwork.png';

    // Convert TJSArrayBufferRecord to Blob
    var TrackBlobData = new Blob([TrackData.jsarraybuffer]);

    // Extract meatadata, if available
    var tag = '';
    async function readMetadataAsync (file) {
      return new Promise((resolve, reject) => {
        jsmediatags.read(file, {
				  onSuccess: resolve,
  				onError: reject
        })
  		})
    }
    try {
      var tag = await readMetadataAsync(TrackBlobData);

      if (tag.tags.title !== undefined) {
        Track = tag.tags.title;
      }

      if (tag.tags.artist !== undefined) {
        Artist = tag.tags.artist;
      }

      if (tag.tags.album !== undefined) {
        Album = tag.tags.album;
      }
      if (tag.tags.picture !== undefined) {
        var image = tag.tags.picture;
        var base64String = "";
        for (var i = 0; i < image.data.length; i++) {
          base64String += String.fromCharCode(image.data[i]);
        }
        Cover = "data:"+tag.tags.picture.format+";base64,"+window.btoa(base64String);
      }
    }
    catch (e) {
      console.log('Data not available for [ '+TrackName+' ]');
    }

    // This is needed to be able to store TrackData as text, so it can be
    // included in the playlists that are saved/loaded
    // https://stackoverflow.com/questions/9267899/arraybuffer-to-base64-encoded-string
    function arrayBufferToBase64(ab){
      var dView = new Uint8Array(ab);
      var arr = Array.prototype.slice.call(dView);
      var arr1 = arr.map(function(item){
        return String.fromCharCode(item);
      });
      return window.btoa(arr1.join(''));
    }

    // Add new track to playlist
    this.tabPlaylist.addRow({
      ID: TrackID,
      TRACKNAME: TrackName,
      TRACKDATA: arrayBufferToBase64(TrackData.jsarraybuffer),
      TRACKBUF:  new Uint8Array(TrackData.jsarraybuffer),
      TRACK: Track,
      ARTIST: Artist,
      ALBUM: Album,
      COVER: Cover
    })
    // If update is true, then make this
    .then(function(row) {
      if (pas.Unit1.Form1.PlayerState == 'Paused') {
        row.select();
        row.getTable().scrollToRow(row);
        divCover.innerHTML = '<image src='+row.getCell("COVER").getValue()+' width=100% height=100%>'
      }
    });

  end;
  {$ENDIF}
end;


procedure TWAAH.LoadAudioTrack(TrackName: String; TrackData: TJSArrayBufferRecord);
begin
  // We've got an audio track to load.  So let's load it.
  {$IFNDEF WIN32}
  asm

    var TrackID = this.NextID + 1;
    pas.WebAudioAPIHelper.WAAH.NextID = TrackID;

    // These are the fields we're looking to populate
    var Track = TrackName;
    var Artist = '';
    var Album = '';
    var Cover = 'images/missingartwork.png';

    // Convert TJSArrayBufferRecord to Blob
    var TrackBlobData = new Blob([TrackData.jsarraybuffer]);

    // Extract meatadata, if available
    var tag = '';
    async function readMetadataAsync (file) {
      return new Promise((resolve, reject) => {
        jsmediatags.read(file, {
				  onSuccess: resolve,
  				onError: reject
        })
  		})
    }
    try {
      var tag = await readMetadataAsync(TrackBlobData);

      if (tag.tags.title !== undefined) {
        Track = tag.tags.title;
      }

      if (tag.tags.artist !== undefined) {
        Artist = tag.tags.artist;
      }

      if (tag.tags.album !== undefined) {
        Album = tag.tags.album;
      }
      if (tag.tags.picture !== undefined) {
        var image = tag.tags.picture;
        var base64String = "";
        for (var i = 0; i < image.data.length; i++) {
          base64String += String.fromCharCode(image.data[i]);
        }
        Cover = "data:"+tag.tags.picture.format+";base64,"+window.btoa(base64String);
      }
    }
    catch (e) {
      console.log('Data not available for [ '+TrackName+' ]');
    }

    const detachedSVG = d3.create("svg");
    var w = 0;
    var h = 52;
    // Lets see if we can get a graph showing the entire clip
    const dataArray = TrackData.jsarraybuffer.slice(0);
    var dataBuffer = null;
    await this.AudioCtx.decodeAudioData(
      dataArray,
      (buffer) => {
        w = buffer.duration * 5.0;
        dataBuffer = buffer;

        const step = Math.floor(
          buffer.getChannelData(0).length / w
        );

        const samplesL = [];
        for (let i = 0; i < w; i++) {
          samplesL.push(buffer.getChannelData(0)[i * step]);
        }
        const samplesR = [];
        for (let i = 0; i < w; i++) {
          samplesR.push(buffer.getChannelData(1)[i * step]);
        }

        detachedSVG.attr("width", w)
                  .attr("height", h);

        const dataL = Array.from(samplesL.entries());
        const dataR = Array.from(samplesR.entries());

        const xValue = d => d[0];
        const yValue = d => d[1];

        const xScale = d3
          .scaleLinear()
          .domain([0, dataL.length - 1])
          .range([0, w]);

        // Draw Channel 0
        detachedSVG.selectAll('.ch0')
          .data(dataL)
          .enter()
          .append('rect')
            .attr('width', ((w / dataL.length) * 0.8))
            .attr('height', function (d) { return Math.abs(yValue(d) * 24)})
            .attr('x', function (d, i) { return (((w / dataL.length) * i) + ((w / dataL.length) * 0.1)) })
            .attr('y', function (d) { return 25 - Math.abs(yValue(d) * 24)})
            .attr('fill', '#fff');

        // Draw Channel 1
        detachedSVG.selectAll('.ch1')
          .data(dataR)
          .enter()
          .append('rect')
            .attr('width', ((w / dataL.length) * 0.8))
            .attr('height', function (d) { return Math.abs(yValue(d) * 24) })
            .attr('x', function (d, i) { return (((w / dataL.length) * i) + ((w / dataL.length) * 0.1)) })
            .attr('y', 25)
            .attr('fill', '#fff')
      },
      (e) => {
        console.log("Error decoding audio data: "+e.error);
      }
    );

    // Add new track to playlist
    this.tabTracklist.addRow({
      ID: TrackID,
      TRACKNAME: TrackName,
      TRACKBUF:  dataBuffer,
      TRACK: Track,
      ARTIST: Artist,
      ALBUM: Album,
      COVER: Cover,
      PLAY: true,
      MUTE: false,
      LOOP: false,
      WAVEFORM: '<div class="Waveform NoPadding" style="position:absolute; width: 100%; height: 100%; top: 0px; left: 0px;">'+
                  '<div id="Track-'+TrackID+'" '+
                    'class="AudioTrack draggableAudio rounded border border-secondary bg-dark"'+
                    'style="width: '+w+'px; top: 2px; left: 1px; height: '+h+'px; color: #fff; overflow:hidden; position:absolute;">'+
                      detachedSVG.node().outerHTML+
                '</div></div>',
      AUDIOSRC: null,
      AUDIOGAIN: null,
      AUDIOPAN: null,
      TRACKGAIN: 5,
      TRACKPAN: 5,
      TRACKPITCH: 5,
      TRACKSPEED: 5,
      CONTROLS: '<div class="CusomTrackbar" title="Gain" style="position:absolute; transform:rotate(-20deg); left:5px; width:90px; height:20px; top:21px;">'+
                '  <div class="rounded border border-dark bg-white" style="position:absolute; width:86px; height:10px; top:5px; left:7px;"></div>'+
                '  <div id="track-Vol-'+TrackID+'"'+
                '          class="draggableTrackbar rounded-pill border border-2"'+
                '          style="cursor:nesw-resize; border-color: #000 !important; background-color: #f00; position:absolute; width: 20px; height: 20px; top: 0px; left:0px;transform:translate(40px,0px)"'+
                '          data-x="40">'+
                '  </div></div>'+
                '<div class="CusomTrackbar" title="Pan" style="position:absolute; transform:rotate(-20deg); left:80px; width:90px; height:20px; top:21px;">'+
                '  <div class="rounded border border-dark bg-white" style="position:absolute; width:86px; height:10px; top:5px; left:7px"></div>'+
                '  <div id="track-Pan-'+TrackID+'"'+
                '          class="draggableTrackbar rounded-pill border border-2"'+
                '          style="cursor:nesw-resize; border-color: #000 !important; background-color: #070; position:absolute; width: 20px; height: 20px; top: 0px; left:0px;transform:translate(40px,0px)"'+
                '          data-x="40">'+
                '  </div></div>'+
                '<div class="CusomTrackbar" title="Pitch" style="position:absolute; transform:rotate(-20deg); left:155px; width:90px; height:20px; top:21px;">'+
                '  <div class="rounded border border-dark bg-white" style="position:absolute; width:86px; height:10px; top:5px; left:7px"></div>'+
                '  <div id="track-Dtn-'+TrackID+'"'+
                '          class="draggableTrackbar rounded-pill border border-2"'+
                '          style="cursor:nesw-resize; border-color: #000 !important; background-color: #00f; position:absolute; width: 20px; height: 20px; top: 0px; left:0px;transform:translate(40px,0px)"'+
                '          data-x="40">'+
                '  </div></div>'+
                '<div class="CusomTrackbar" title="Speed" style="position:absolute; transform:rotate(-20deg); left:230px; width:90px; height:20px; top:21px;">'+
                '  <div class="rounded border border-dark bg-white" style="position:absolute; width:86px; height:10px; top:5px; left:7px"></div>'+
                '  <div id="track-Spd-'+TrackID+'"'+
                '          class="draggableTrackbar rounded-pill border border-2"'+
                '          style="cursor:nesw-resize; border-color: #000 !important; background-color: #ff0; position:absolute; width: 20px; height: 20px; top: 0px; left:0px;transform:translate(40px,0px)"'+
                '          data-x="40">'+
                '  </div></div>'
    })
    // If update is true, then make this
    .then(function(row) {
        row.select();
        row.getTable().scrollToRow(row);
        pas.WebAudioAPIHelper.WAAH.tabTracklist.getColumn('WAVEFORM').setWidth(
          pas.Unit1.Form1.ProjectTime * pas.Unit1.Form1.ZoomLevel
        );
    });

  end;
  {$ENDIF}

end;

procedure TWAAH.RemoveTrack;
begin
  // Remove selected tracks from the playlist
  asm
    var rows = this.tabPlaylist.getSelectedRows();
    for (var i = 0; i < rows.length; i++) {
      this.tabPlaylist.deleteRow(rows[i]);
    }
  end;
end;

procedure TWAAH.ResetProject;
begin
  asm
    this.tabTracklist.clearData();
  end;
end;

procedure TWAAH.RedrawTracklist;
begin
  asm
    if (this.tabTracklistReady == true) {
      setTimeout(function() {
        pas.WebAudioAPIHelper.WAAH.tabTracklist.getColumn('WAVEFORM').setWidth(
          pas.Unit1.Form1.ProjectTime * pas.Unit1.Form1.ZoomLevel
        );
      },100);
    }
  end;
end;

procedure TWAAH.RemoveAudioTrack;
begin
  // Remove selected tracks from the playlist
  asm
    var rows = this.tabTracklist.getSelectedRows();
    for (var i = 0; i < rows.length; i++) {
      this.tabTracklist.deleteRow(rows[i]);
    }

    var TrackID = this.tabTracklist.getCalcResults().top.ID;
    if (isNaN(TrackID)) { TrackID = 0; }
    pas.WebAudioAPIHelper.WAAH.NextID = TrackID;
  end;
end;

procedure TWAAH.SavePlaylist;
begin
  // Just save the entire contents of the Tabulator table
  asm
    var playlist = JSON.stringify(this.tabPlaylist.getData());
    var blob = new Blob([playlist], {type: "text/plain;charset=utf-8"});
    var streamSaver = window.streamSaver;
    const fileStream = streamSaver.createWriteStream('New Playlist.playlist', {
      size: blob.size // Makes the procentage visiable in the download
    })
    const readableStream = blob.stream()
    window.writer = fileStream.getWriter()
    const reader = readableStream.getReader()
    const pump = () => reader.read()
      .then(res => res.done
            ? writer.close()
            : writer.write(res.value).then(pump))
    pump()
  end;
end;

procedure TWAAH.SaveProject;
begin
  // Just save the entire contents of the Tabulator table
  asm
    var project = JSON.stringify(this.tabTracklist.getData());
    var blob = new Blob([project], {type: "text/plain;charset=utf-8"});
    var streamSaver = window.streamSaver;
    const fileStream = streamSaver.createWriteStream('New Project.trackeditor', {
      size: blob.size // Makes the procentage visiable in the download
    })
    const readableStream = blob.stream()
    window.writer = fileStream.getWriter()
    const reader = readableStream.getReader()
    const pump = () => reader.read()
      .then(res => res.done
            ? writer.close()
            : writer.write(res.value).then(pump))
    pump()
  end;
end;

procedure TWAAH.SetVolume(volume: double);
begin
  asm
    this.AudioGain.gain.value = volume;
  end;
end;

procedure TWAAH.ShufflePlaylist;
begin
  asm
    var rowcount = this.tabPlaylist.getDataCount();
    for (var i = 1; i <= rowcount; i++) {
      var row = this.tabPlaylist.getRowFromPosition(i);
      row.move(this.tabPlaylist.getRowFromPosition(1+Math.floor(Math.random() * (rowcount - 1)),true));
    }
  end;
end;

procedure TWAAH.SwapEditMode(EditMode: Boolean);
begin
  asm
    var tracks = document.getElementsByClassName('AudioTrack');
    for (var i = 0; i < tracks.length; i++) {
      if (EditMode == false) {
        tracks[i].classList.replace('draggableAudioPitch', 'draggableAudio');
      }
      else {
        tracks[i].classList.replace('draggableAudio', 'draggableAudioPitch');
      }
    }
  end;
end;

procedure TWAAH.VolumeChanged(Value: Integer);
begin
  // Value = range 1..9
  asm
    const volarray = [0.00, 0.25, 0.50, 0.75, 1.00, 1.25, 1.50, 1.75, 2.00]
    this.AudioGain.gain.value = volarray[Value-1];
  end;
end;

procedure TWAAH.WebDataModuleCreate(Sender: TObject);
begin
  // Certain things we can't do until the table is ready
  tabTrackListReady := False;

  // Used to help keep track of track numbering
  NextID := 0;

  // Used for the Interact.js library that handles dragging and resizing
  asm

    // These are used for the trackbar / range sliders

    function draggableTrackbarListener (event) {
      var target = event.target;
      var oldx = parseFloat(target.getAttribute('data-x')) || 0;
      var offx = event.dx;
      var newx = (10*Math.ceil(oldx/10))+(10*Math.ceil(offx/10));
      if (newx <  0) {newx =  0}
      if (newx > 80) {newx = 80}
      target.style.transform = 'translate(' + newx + 'px, 0px)'
      target.setAttribute('data-x', newx)

      // Is this one of the trackbars from the table?
      if (target.id.indexOf('track-') >= 0 ) {
        var rowid = target.id.substr(10,5);
        var typ = target.id.substr(6,3);
        var table = pas.WebAudioAPIHelper.WAAH.tabTracklist;
        var row = table.getRow(rowid);
        row.select();

        if (typ == 'Vol') {
          row.getCell('TRACKGAIN').setValue(1 + parseInt(newx / 10));
          if (row.getCell('AUDIOGAIN').getValue() !== null) {
            const volarray = [0.00, 0.25, 0.50, 0.75, 1.00, 1.25, 1.50, 1.75, 2.00]
            row.getCell('AUDIOGAIN').getValue().gain.value = volarray[parseInt(newx /10)]
            row.getCell('MUTE').setValue(false);
          }
        }
        else if (typ == 'Pan') {
          row.getCell('TRACKPAN').setValue(1 + parseInt(newx / 10));
          if (row.getCell('AUDIOPAN').getValue() !== null) {
            const panarray = [-1.00, -0.75, -0.50, -0.25, 0.00, 0.25, 0.50, 0.75, 1.00]
            row.getCell('AUDIOPAN').getValue().pan.value = panarray[parseInt(newx /10)]
          }
        }
        else if (typ == 'Dtn') {
          row.getCell('TRACKPITCH').setValue(1 + parseInt(newx / 10));
          if (row.getCell('AUDIOSRC').getValue() !== null) {
            const detunearray = [-2400, -1800, -1200, -600, 0, 600, 1200, 1800, 2400]
            row.getCell('AUDIOSRC').getValue().detune.value = detunearray[parseInt(newx /10)]
          }
        }
        else if (typ == 'Spd') {
          row.getCell('TRACKSPEED').setValue(1 + parseInt(newx / 10));
          if (row.getCell('AUDIOSRC').getValue() !== null) {
            const ratearray = [0.2, 0.4, 0.6, 0.8, 1.0, 1.2, 1.4, 1.6, 1.8]
            row.getCell('AUDIOSRC').getValue().playbackRate.value = ratearray[parseInt(newx /10)]
          }
        }
      }
      else {
        switch(String(target.id)) {
          case "trackerZoom"    : pas.Unit1.Form1.trackerZoomChanged(1 + parseInt(newx / 10)); break;
          case "trackerTime"    : pas.Unit1.Form1.trackerTimeChanged(1 + parseInt(newx / 10)); break;
          case "trackerVolume"  : pas.Unit1.Form1.trackerVolumeChanged(1 + parseInt(newx / 10)); break;
          case "trackerBalance" : pas.Unit1.Form1.trackerBalanceChanged(1 + parseInt(newx / 10)); break;
        }
      }
    }
    window.draggableTrackbarListener = draggableTrackbarListener

    interact('.draggableTrackbar')
      .styleCursor(false)
      .draggable({
        modifiers: [
          interact.modifiers.snap({
            targets: [
             { x: 10, y: 0 },
             { x: 20, y: 0 },
             { x: 30, y: 0 },
             { x: 40, y: 0 },
             { x: 50, y: 0 },
             { x: 60, y: 0 },
             { x: 70, y: 0 },
             { x: 80, y: 0 },
             { x: 90, y: 0 }
            ],
            offset: 'parent'
          })
        ],
        listeners: {
          move: draggableTrackbarListener
      }})


    // These are used by the waveforms in "trim" mode

    function draggableAudioListener (event) {
      var target = event.target
      var x = (parseFloat(target.getAttribute('data-x')) || 0) + event.dx
      target.style.transform = 'translate(' + x + 'px, 0px)'
      target.setAttribute('data-x', x)
    }
    window.draggableAudioListener = draggableAudioListener

    interact('.draggableAudio')
      .resizable({
        edges: { left: true, right: true, bottom: false, top: false},
        listeners: {
          move (event) {
            var target = event.target
            var x = (parseFloat(target.getAttribute('data-x')) || 0)
            target.style.width = event.rect.width + 'px'
            x += event.deltaRect.left
            target.style.transform = 'translate(' + x + 'px, 0px)'
            target.setAttribute('data-x', x)
            if (event.edges.left == true) {
              var tl = target.getAttribute('data-tl') || 0;
              tl -= event.deltaRect.left;
              target.setAttribute('data-tl', tl);
              target.firstElementChild.style.transform = 'translateX('+tl+'px)';
            }
            if (event.edges.right == true) {
              var tr = target.getAttribute('data-tr') || 0;
              tr -= event.deltaRect.right;
              target.setAttribute('data-tr', tr);
            }
          }
        },
        inertia: true,
        modifiers: [
          interact.modifiers.restrictEdges({
            outer: 'parent'
          }),
          interact.modifiers.restrictSize({
            min: { width: 30 }
      })]})
      .draggable({
        listeners: { move: window.draggableAudioListener },
        inertia: true,
      })


    // These are used by the waveforms in "pitch" mode

    function draggableAudioPitchListener (event) {
      var target = event.target
      var x = (parseFloat(target.getAttribute('data-x')) || 0) + event.dx
      target.style.transform = 'translate(' + x + 'px, 0px)'
      target.setAttribute('data-x', x)
    }
    window.draggableAudioPitchListener = draggableAudioPitchListener

    interact('.draggableAudioPitch')
      .resizable({
        edges: { left: true, right: true, bottom: false, top: false},
        listeners: {
          move (event) {
            var target = event.target
            var x = (parseFloat(target.getAttribute('data-x')) || 0)
            var tl = (parseFloat(target.getAttribute('data-tl')) || 0)
            var tr = (parseFloat(target.getAttribute('data-tr')) || 0)
            x += event.deltaRect.left
            target.style.transform = 'translate(' + x + 'px, 0px)'

            var svgw = target.firstElementChild.getAttribute('width');
            var scale = (event.rect.width + tl + tr) / svgw;
            target.setAttribute('data-s', scale)

            target.parentElement.style.transformOrigin = x+'px 0px';
            target.parentElement.style.transform = 'scaleX('+scale+')';
          }
        },
        inertia: true,
        modifiers: [
          interact.modifiers.restrictEdges({
            outer: 'parent'
          }),
          interact.modifiers.restrictSize({
            min: { width: 30 }
      })]})
      .draggable({
        listeners: { move: window.draggableAudioPitchListener },
        inertia: true,
      })


    function draggableCursorListener (event) {
      var target = event.target
      var x = (parseFloat(target.getAttribute('data-x')) || 0) + event.dx
      target.style.transform = 'translate(' + x + 'px, 0px)'
      target.setAttribute('data-x', x)
    }
    window.draggableCursorListener = draggableCursorListener

    interact('.draggableCursor')
      .draggable({
        listeners: { move: window.draggableCursorListener },
        inertia: true,
      })


  end;
end;



procedure TWAAH.LoadPlaylist(data: String);
var
  TrackID: Integer;
begin
  // Just set the contents of the Tabulator table
  asm
    this.tabPlaylist.setData(JSON.parse(data)).
    then(function() {
      var table = pas.WebAudioAPIHelper.WAAH.tabPlaylist;
      if (table.getDataCount() > 0) {
        table.selectRow(table.getRowFromPosition(1));
      }

      TrackID = table.getCalcResults().top.ID + 1;
      if (isNaN(TrackID)) {
        TrackID = 1;
      }
      pas.WebAudioAPIHelper.WAAH.NextID = TrackID;

    });
  end;
end;

procedure TWAAH.LoadPreviousTrack;
begin
  asm
    var rows = this.tabPlaylist.getSelectedRows();
    if (rows.length !== 0) {
      var rowposition = rows[0].getPosition();
      if (rowposition == 1) {
        rowposition = this.tabPlaylist.getDataCount()
      }
      else {
        rowposition = rowposition - 1;
      }
      this.tabPlaylist.deselectRow();
      this.tabPlaylist.selectRow(this.tabPlaylist.getRowFromPosition(rowposition));
      pas.WebAudioAPIHelper.WAAH.PlayAudio(0);
    }
  end;
end;

procedure TWAAH.LoadProject(data: String);
var
  TrackID: Integer;
begin
  // Just set the contents of the Tabulator table
  asm
    this.tabtracklist.setData(JSON.parse(data)).
    then(function() {
      var table = pas.WebAudioAPIHelper.WAAH.tabTracklist;
      if (table.getDataCount() > 0) {
        table.selectRow(table.getRowFromPosition(1));
      }

      TrackID = table.getCalcResults().top.ID;
      if (isNaN(TrackID)) {
        TrackID = 0;
      }
      pas.WebAudioAPIHelper.WAAH.NextID = TrackID;

    });
  end;
end;

procedure TWAAH.LoadNextTrack;
begin
  asm
    var rows = this.tabPlaylist.getSelectedRows();
    if (rows.length !== 0) {
      var rowposition = rows[0].getPosition();
      if (rowposition < this.tabPlaylist.getDataCount()) {
        rowposition = rowposition + 1;
      }
      else {
        rowposition = 1;
      }
      this.tabPlaylist.deselectRow();
      this.tabPlaylist.selectRow(this.tabPlaylist.getRowFromPosition(rowposition));
      pas.WebAudioAPIHelper.WAAH.PlayAudio(0);
    }
  end;
end;

end.
