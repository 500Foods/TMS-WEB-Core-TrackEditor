unit Unit1;

interface

uses
  System.SysUtils, System.Classes, JS, Web, WEBLib.Graphics, WEBLib.Controls,
  WEBLib.Forms, WEBLib.Dialogs, Vcl.Controls, WEBLib.WebCtrls, Vcl.StdCtrls,
  WEBLib.StdCtrls, VCL.TMSFNCCustomControl, VCL.TMSFNCTrackBar, WEBLib.Buttons,
  WEBLib.ExtCtrls;

type
  TForm1 = class(TWebForm)
    divMain: TWebHTMLDiv;
    divTop: TWebHTMLDiv;
    divBottom: TWebHTMLDiv;
    divVisualizer: TWebHTMLDiv;
    divMiddle: TWebHTMLDiv;
    divTopLeft: TWebHTMLDiv;
    WebHTMLDiv2: TWebHTMLDiv;
    divBottomLeft: TWebHTMLDiv;
    divBottomMiddle: TWebHTMLDiv;
    divBottomRight: TWebHTMLDiv;
    btnLoadTrack: TWebButton;
    WebOpenDialogTracks: TWebOpenDialog;
    btnRecordTrack: TWebButton;
    btnCopyTrack: TWebButton;
    btnRemoveTrack: TWebButton;
    btnCreateTrack: TWebButton;
    btnInstrumentLibrary: TWebButton;
    divTimeline: TWebHTMLDiv;
    divTimelineLeft: TWebHTMLDiv;
    divTimelineMiddle: TWebHTMLDiv;
    divTimelineRight: TWebHTMLDiv;
    divTimelineChart: TWebHTMLDiv;
    divZoomHolder: TWebHTMLDiv;
    btnSaveProject: TWebButton;
    btnLoadProject: TWebButton;
    WebButton4: TWebButton;
    btnReset: TWebButton;
    divTimeHolder: TWebHTMLDiv;
    labelZoom: TWebLabel;
    labelTime: TWebLabel;
    toggleEditMode: TWebToggleButton;
    labelEditMode: TWebLabel;
    btnPlay: TWebButton;
    divMasterVolumeHolder: TWebHTMLDiv;
    divMasterPanHolder: TWebHTMLDiv;
    btnMute: TWebButton;
    btnExport: TWebButton;
    divCursor: TWebHTMLDiv;
    tmrCursor: TWebTimer;
    divElapsed: TWebLabel;
    divRemaining: TWebLabel;
    procedure WebFormCreate(Sender: TObject);
    [async]procedure btnLoadTrackClick(Sender: TObject);
    procedure WebOpenDialogTracksGetFileAsArrayBuffer(Sender: TObject; AFileIndex: Integer; ABuffer: TJSArrayBufferRecord);
    procedure trackerZoomChanged(Value: integer);
    procedure trackerTimeChanged(Value: integer);
    procedure trackerVolumeChanged(Value: integer);
    procedure trackerBalanceChanged(Value: integer);
    procedure btnRemoveTrackClick(Sender: TObject);
    procedure btnCopyTrackClick(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
    procedure WebFormResize(Sender: TObject);
    procedure toggleEditModeClick(Sender: TObject);
    procedure btnPlayClick(Sender: TObject);
    procedure btnMuteClick(Sender: TObject);
    procedure tmrCursorTimer(Sender: TObject);
    procedure btnExportClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    PlayingState: Boolean;
    MuteState: Boolean;
    CurrentVolume: Integer;
    ProjectTime: Integer;
    ZoomLevel: Integer;
    EditMode: Boolean;

  end;

var
  Form1: TForm1;

implementation

uses WebAudioAPIHelper;

{$R *.dfm}

procedure TForm1.trackerZoomChanged(Value: integer);
begin
  // Time Scale has changed
  Form1.labelZoom.HTML := '<div style="z-index: -1; font-size: 11px; color: pink;; line-height: 1;">Zoom<br />'+IntToStr(10-Value)+'</div>';
  Form1.ZoomLevel := 10 - Value;
  WAAH.DrawTimeline(ZoomLevel, Form1.ProjectTime, 'divTimelineChart');
end;

procedure TForm1.tmrCursorTimer(Sender: TObject);
begin
  // Update the Curosr
  divCursor.Left := WAAH.GetCursorPosition;
end;

procedure TForm1.toggleEditModeClick(Sender: TObject);
begin
  EditMode := toggleEditMode.Checked;

  if EditMode = False then
  begin
    labelEditMode.HTML := '<div style="font-size: 12px; color: white; font-weight:500;">Trim<span style="font-weight:400; color: gray;"> / Pitch</span></div>';
  end
  else
  begin
    labelEditMode.HTML := '<div style="font-size: 12px; color: gray; font-weight:400;">Trim / <span style="font-weight:500; color: white;">Pitch</span></div>';
  end;

  WAAH.SwapEditMode(EditMode);
end;

procedure TForm1.trackerBalanceChanged(Value: integer);
begin
  WAAH.BalanceChanged(Value);
end;

procedure TForm1.trackerTimeChanged(Value: integer);
begin
  // Project Duration
  Form1.labelTime.HTML := '<div style="z-index: -1; font-size: 11px; color: orange;; line-height: 1;">'+IntToStr(Value)+'m<br />Time</div>';
  Form1.ProjectTime := Value * 60;
  WAAH.DrawTimeline(Form1.ZoomLevel, Form1.ProjectTime, 'divTimelineChart');
end;

procedure TForm1.trackerVolumeChanged(Value: integer);
begin
  WAAH.VolumeChanged(Value);
  CurrentVolume := Value;
  MuteState := False;
  btnMute.Caption := '<i class="fa-solid fa-volume-off text-secondary fa-xl"></i>';
end;

procedure TForm1.btnCopyTrackClick(Sender: TObject);
begin
  WAAH.CloneAudioTrack;
end;

procedure TForm1.btnExportClick(Sender: TObject);
begin
  WAAH.ExportProject;
end;

procedure TForm1.btnLoadTrackClick(Sender: TObject);
var
  i: Integer;
begin
  // Open file dialog
  await(string, WebOpenDialogTracks.Perform);

  // If files were selected, iterate through them
  i := 0;
  while (i < WebOpenDialogTracks.Files.Count) do
  begin
    WebOpenDialogTracks.Files.Items[i].GetFileAsArrayBuffer;
    i := i + 1;
  end;
end;

procedure TForm1.btnMuteClick(Sender: TObject);
begin
  MuteState := not(MuteState);
  if MuteState = True then
  begin
    btnMute.Caption := '<i class="fa-solid fa-volume-off text-white fa-xl"></i>';
    WAAH.VolumeChanged(1);
  end
  else
  begin
    btnMute.Caption := '<i class="fa-solid fa-volume-off text-secondary fa-xl"></i>';
    WAAH.VolumeChanged(CurrentVolume);
  end;
end;


procedure TForm1.btnPlayClick(Sender: TObject);
begin
  PlayingState := not(PlayingState);

  if PlayingState = True then
  begin
    btnPlay.Caption := '<i class="fa-solid fa-pause fa-3x"></i>';
    WAAH.DrawVisualizer;
    WAAH.PlayProject;
    tmrCursor.Enabled := True;
  end
  else
  begin
    btnPlay.Caption := '<i class="fa-solid fa-play fa-3x"></i>';
    WAAH.StopProject;
    tmrCursor.Enabled := False;
    divCursor.Left := 384;
  end;
end;

procedure TForm1.btnRemoveTrackClick(Sender: TObject);
begin
  WAAH.RemoveAudioTrack;
end;

procedure TForm1.btnResetClick(Sender: TObject);
begin
  WAAH.ResetProject;
end;


procedure TForm1.WebFormCreate(Sender: TObject);
begin

  // Defaults
  PlayingState := False; // Not playing
  MuteState := False;    // Not Muted
  CurrentVolume := 5;    // Corresponds to AudioParam gain = 1
  ZoomLevel := 5;        // 5 pixels per second
  ProjectTime := 300;    // 5 minutes

  // Initialize main list
  WAAH.InitializeTrackList(divMiddle.ElementID);

  // Intialize AudioContext
  WAAH.InitializeAudio;


end;

procedure TForm1.WebFormResize(Sender: TObject);
begin
  // Redraw Tracklist
  WAAH.RedrawTracklist;

  // Configure Cursor
  divCursor.Height := divMiddle.Height + 29;
end;

procedure TForm1.WebOpenDialogTracksGetFileAsArrayBuffer(Sender: TObject;
  AFileIndex: Integer; ABuffer: TJSArrayBufferRecord);
begin
  WAAH.LoadAudioTrack( WebOpenDialogTracks.Files.Items[AfileIndex].Name, ABuffer);
end;

end.