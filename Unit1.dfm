object Form1: TForm1
  Width = 1098
  Height = 702
  CSSLibrary = cssBootstrap
  ElementFont = efCSS
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Tahoma'
  Font.Style = []
  ParentFont = False
  OnCreate = WebFormCreate
  OnResize = WebFormResize
  object divMain: TWebHTMLDiv
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 1092
    Height = 696
    ElementClassName = 'rounded-3 bg-dark border border-1 border-secondary'
    ElementID = 'divMain'
    Align = alClient
    ElementFont = efCSS
    Role = ''
    object divTop: TWebHTMLDiv
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 1086
      Height = 86
      ElementClassName = 'rounded-3 bg-black border border-secondary'
      ElementID = 'divTop'
      Align = alTop
      ElementFont = efCSS
      Role = ''
      object divVisualizer: TWebHTMLDiv
        AlignWithMargins = True
        Left = 384
        Top = 3
        Width = 320
        Height = 80
        Margins.Left = 0
        Margins.Right = 0
        ElementClassName = 'rounded bg-dark overflow-hidden'
        ElementID = 'divVisualizer'
        Align = alClient
        ElementFont = efCSS
        Role = ''
      end
      object divTopLeft: TWebHTMLDiv
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 378
        Height = 80
        ElementClassName = 'rounded bg-dark overflow-hidden'
        ElementID = 'divTopLeft'
        Align = alLeft
        ChildOrder = 1
        ElementFont = efCSS
        Role = ''
        object btnSaveProject: TWebButton
          AlignWithMargins = True
          Left = 156
          Top = 8
          Width = 54
          Height = 64
          Hint = 'Download Project'
          Margins.Left = 8
          Margins.Top = 8
          Margins.Right = 8
          Margins.Bottom = 8
          Align = alLeft
          Caption = '<i class="fa-solid fa-download fa-3x"></i>'
          ChildOrder = 2
          ElementClassName = 'btn btn-dark text-white'
          ElementID = 'btnSaveProject'
          ElementFont = efCSS
          HeightStyle = ssAuto
          HeightPercent = 100.000000000000000000
          ShowHint = True
          WidthStyle = ssAuto
          WidthPercent = 100.000000000000000000
          ExplicitLeft = 148
        end
        object btnLoadProject: TWebButton
          AlignWithMargins = True
          Left = 86
          Top = 8
          Width = 54
          Height = 64
          Hint = 'Upload Project'
          Margins.Left = 16
          Margins.Top = 8
          Margins.Right = 8
          Margins.Bottom = 8
          Align = alLeft
          Caption = '<i class="fa-solid fa-upload fa-3x"></i>'
          ChildOrder = 3
          ElementClassName = 'btn btn-dark text-white'
          ElementID = 'btnLoadProject'
          ElementFont = efCSS
          HeightStyle = ssAuto
          HeightPercent = 100.000000000000000000
          ShowHint = True
          WidthStyle = ssAuto
          WidthPercent = 100.000000000000000000
          ExplicitLeft = 78
        end
        object WebButton4: TWebButton
          AlignWithMargins = True
          Left = 8
          Top = 8
          Width = 54
          Height = 64
          Hint = 'Load Track'
          Margins.Left = 8
          Margins.Top = 8
          Margins.Right = 8
          Margins.Bottom = 8
          Align = alLeft
          Caption = '<i class="fa-solid fa-music fa-3x"></i>'
          ChildOrder = 4
          ElementClassName = 'btn btn-link text-decoration-none'
          ElementID = 'buttonEditor'
          ElementFont = efCSS
          HeightStyle = ssAuto
          HeightPercent = 100.000000000000000000
          ShowHint = True
          WidthStyle = ssAuto
          WidthPercent = 100.000000000000000000
        end
        object btnReset: TWebButton
          AlignWithMargins = True
          Left = 226
          Top = 8
          Width = 54
          Height = 64
          Hint = 'New Project'
          Margins.Left = 8
          Margins.Top = 8
          Margins.Right = 8
          Margins.Bottom = 8
          Align = alLeft
          Caption = '<i class="fa-solid fa-recycle fa-3x"></i>'
          ChildOrder = 2
          ElementClassName = 'btn btn-dark text-white'
          ElementID = 'btnResetProject'
          ElementFont = efCSS
          HeightStyle = ssAuto
          HeightPercent = 100.000000000000000000
          ShowHint = True
          WidthStyle = ssAuto
          WidthPercent = 100.000000000000000000
          OnClick = btnResetClick
          ExplicitLeft = 316
        end
      end
      object WebHTMLDiv2: TWebHTMLDiv
        AlignWithMargins = True
        Left = 707
        Top = 3
        Width = 376
        Height = 80
        ElementClassName = 'rounded bg-dark'
        ElementID = 'divTopRight'
        Align = alRight
        ChildOrder = 2
        ElementFont = efCSS
        Role = ''
        object btnPlay: TWebButton
          AlignWithMargins = True
          Left = 292
          Top = 8
          Width = 76
          Height = 64
          Hint = 'Upload Project'
          Margins.Left = 0
          Margins.Top = 8
          Margins.Right = 8
          Margins.Bottom = 8
          Align = alRight
          Caption = '<i class="fa-solid fa-play fa-3x"></i>'
          ChildOrder = 3
          ElementClassName = 'btn btn-dark text-white'
          ElementID = 'btnPlay'
          ElementFont = efCSS
          HeightStyle = ssAuto
          HeightPercent = 100.000000000000000000
          ShowHint = True
          WidthPercent = 100.000000000000000000
          OnClick = btnPlayClick
          ExplicitLeft = 322
        end
        object divMasterVolumeHolder: TWebHTMLDiv
          Left = 37
          Top = 12
          Width = 100
          Height = 56
          ElementID = 'divMasterVolumeHolder'
          ChildOrder = 1
          ElementFont = efCSS
          HTML.Strings = (
            
              '<div class="CusomTrackbar" title="Master Volume" style="z-index:' +
              ' 10; position:absolute; transform:rotate(-20deg); left:5px; widt' +
              'h:100px; height:20px; top:17px;">'
            
              '  <div class="rounded border bg-white" style="border-color: #000' +
              ' !important; position:absolute; width:86px; height:10px; top:5px' +
              '; left:7px"></div>'
            '  <div id="trackerVolume"'
            '          class="draggableTrackbar rounded-pill border border-2"'
            
              '          style="cursor:nesw-resize; border-color:#000 !importan' +
              't; background-color: #f00; position:absolute; width: 20px; heigh' +
              't: 20px; top: 0px; '
            'left:0px;transform:translate(40px,0px)" '
            '          data-x="40">'
            '  </div>'
            '</div>')
          Role = ''
        end
        object divMasterPanHolder: TWebHTMLDiv
          Left = 112
          Top = 12
          Width = 100
          Height = 56
          ElementID = 'divMasterPanHolder'
          ChildOrder = 2
          ElementFont = efCSS
          HTML.Strings = (
            
              '<div class="CusomTrackbar" title="Master Balance" style="positio' +
              'n:absolute; transform:rotate(-20deg); left:5px; width:100px; hei' +
              'ght:20px; top:17px;">'
            
              '  <div class="rounded border bg-white" style="border-color: #000' +
              ' !important; position:absolute; width:86px; height:10px; top:5px' +
              '; left:7px"></div>'
            '  <div id="trackerBalance"'
            '          class="draggableTrackbar rounded-pill border border-2"'
            
              '          style="cursor:nesw-resize; border-color:#000 !importan' +
              't; background-color: #070; position:absolute; width: 20px; heigh' +
              't: 20px; top: 0px; '
            'left:0px;transform:translate(40px,0px)" '
            '          data-x="40">'
            '  </div>'
            '</div>')
          Role = ''
        end
        object btnMute: TWebButton
          AlignWithMargins = True
          Left = -2
          Top = 18
          Width = 54
          Height = 54
          Hint = 'Master Mute'
          Margins.Left = 8
          Margins.Top = 8
          Margins.Right = 8
          Margins.Bottom = 8
          Caption = '<i class="fa-solid fa-volume-off text-secondary fa-xl"></i>'
          ChildOrder = 2
          ElementClassName = 'btn btn-link text-decoration-none'
          ElementID = 'btnMute'
          ElementFont = efCSS
          HeightStyle = ssAuto
          HeightPercent = 100.000000000000000000
          ShowHint = True
          WidthStyle = ssAuto
          WidthPercent = 100.000000000000000000
          OnClick = btnMuteClick
        end
        object btnExport: TWebButton
          AlignWithMargins = True
          Left = 238
          Top = 8
          Width = 54
          Height = 64
          Hint = 'Export MP3'
          Margins.Left = 0
          Margins.Top = 8
          Margins.Right = 0
          Margins.Bottom = 8
          Align = alRight
          Caption = '<i class="fa-solid fa-bullseye fa-3x"></i>'
          ChildOrder = 3
          ElementClassName = 'btn btn-dark text-white'
          ElementID = 'btnExport'
          ElementFont = efCSS
          HeightStyle = ssAuto
          HeightPercent = 100.000000000000000000
          ShowHint = True
          WidthStyle = ssAuto
          WidthPercent = 100.000000000000000000
          OnClick = btnExportClick
          ExplicitLeft = 78
        end
      end
    end
    object divBottom: TWebHTMLDiv
      AlignWithMargins = True
      Left = 3
      Top = 631
      Width = 1086
      Height = 62
      ElementClassName = 'rounded-3 bg-black border border-secondary'
      ElementID = 'divBottom'
      Align = alBottom
      ChildOrder = 1
      ElementFont = efCSS
      Role = ''
      object divBottomLeft: TWebHTMLDiv
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 376
        Height = 56
        ElementClassName = 'rounded bg-dark'
        ElementID = 'divBottomLeft'
        Align = alLeft
        ChildOrder = 1
        ElementFont = efCSS
        Role = ''
        object btnLoadTrack: TWebButton
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 54
          Height = 50
          Hint = 'Load Track'
          Align = alLeft
          Caption = '<i class="fa-solid fa-plus fa-2x"></i>'
          ElementClassName = 'btn btn-dark text-white '
          ElementID = 'btnLoadTrack'
          ElementFont = efCSS
          HeightStyle = ssAuto
          HeightPercent = 100.000000000000000000
          ShowHint = True
          WidthStyle = ssAuto
          WidthPercent = 100.000000000000000000
          OnClick = btnLoadTrackClick
        end
        object btnRecordTrack: TWebButton
          AlignWithMargins = True
          Left = 63
          Top = 3
          Width = 54
          Height = 50
          Hint = 'Record Track'
          Align = alLeft
          Caption = '<i class="fa-solid fa-microphone fa-2x"></i>'
          ChildOrder = 1
          ElementClassName = 'btn btn-dark text-white '
          ElementID = 'btnRecordTrack'
          ElementFont = efCSS
          HeightStyle = ssAuto
          HeightPercent = 100.000000000000000000
          ShowHint = True
          WidthStyle = ssAuto
          WidthPercent = 100.000000000000000000
        end
        object btnCopyTrack: TWebButton
          AlignWithMargins = True
          Left = 243
          Top = 3
          Width = 54
          Height = 50
          Hint = 'Clone Track'
          Align = alLeft
          Caption = '<i class="fa-solid fa-clone fa-2x"></i>'
          ChildOrder = 1
          ElementClassName = 'btn btn-dark text-white '
          ElementID = 'btnCopyTrack'
          ElementFont = efCSS
          HeightStyle = ssAuto
          HeightPercent = 100.000000000000000000
          ShowHint = True
          WidthStyle = ssAuto
          WidthPercent = 100.000000000000000000
          OnClick = btnCopyTrackClick
        end
        object btnRemoveTrack: TWebButton
          AlignWithMargins = True
          Left = 303
          Top = 3
          Width = 54
          Height = 50
          Hint = 'Remove Track'
          Align = alLeft
          Caption = '<i class="fa-solid fa-trash-can fa-2x"></i>'
          ChildOrder = 1
          ElementClassName = 'btn btn-dark text-white '
          ElementID = 'btnRemoveTrack'
          ElementFont = efCSS
          HeightStyle = ssAuto
          HeightPercent = 100.000000000000000000
          ShowHint = True
          WidthStyle = ssAuto
          WidthPercent = 100.000000000000000000
          OnClick = btnRemoveTrackClick
        end
        object btnCreateTrack: TWebButton
          AlignWithMargins = True
          Left = 123
          Top = 3
          Width = 54
          Height = 50
          Hint = 'Create Track'
          Align = alLeft
          Caption = '<i class="fa-solid fa-wave-square fa-2x"></i>'
          ChildOrder = 1
          ElementClassName = 'btn btn-dark text-white '
          ElementID = 'btnCreateTrack'
          ElementFont = efCSS
          HeightStyle = ssAuto
          HeightPercent = 100.000000000000000000
          ShowHint = True
          WidthStyle = ssAuto
          WidthPercent = 100.000000000000000000
        end
        object btnInstrumentLibrary: TWebButton
          AlignWithMargins = True
          Left = 183
          Top = 3
          Width = 54
          Height = 50
          Hint = 'InstrumentLibrary'
          Align = alLeft
          Caption = '<i class="fa-solid fa-guitar fa-2x"></i>'
          ChildOrder = 1
          ElementClassName = 'btn btn-dark text-white '
          ElementID = 'btnInstrumentTrack'
          ElementFont = efCSS
          HeightStyle = ssAuto
          HeightPercent = 100.000000000000000000
          ShowHint = True
          WidthStyle = ssAuto
          WidthPercent = 100.000000000000000000
        end
      end
      object divBottomMiddle: TWebHTMLDiv
        AlignWithMargins = True
        Left = 382
        Top = 3
        Width = 322
        Height = 56
        Margins.Left = 0
        Margins.Right = 0
        ElementClassName = 'rounded bg-dark'
        ElementID = 'divBottomMiddle'
        Align = alClient
        ChildOrder = 1
        ElementFont = efCSS
        Role = ''
      end
      object divBottomRight: TWebHTMLDiv
        AlignWithMargins = True
        Left = 707
        Top = 3
        Width = 376
        Height = 56
        ElementClassName = 'rounded bg-dark overflow-hidden'
        ElementID = 'divBottomRight'
        Align = alRight
        ChildOrder = 2
        ElementFont = efCSS
        Role = ''
        ExplicitTop = 0
        object labelZoom: TWebLabel
          Left = 205
          Top = 3
          Width = 65
          Height = 18
          Caption = 'labelZoom'
          ElementLabelClassName = 'text-white'
          ElementID = 'labelZoom'
          ElementFont = efCSS
          HeightPercent = 100.000000000000000000
          HTML = 
            '<div style="z-index: 0; font-size: 11px; color: pink; line-heigh' +
            't: 1;">Zoom<br />5</div>'
          WidthPercent = 100.000000000000000000
        end
        object labelTime: TWebLabel
          Left = 335
          Top = 30
          Width = 587
          Height = 18
          Alignment = taRightJustify
          Caption = 'labelTime'
          ElementLabelClassName = 'text-white'
          ElementID = 'labelTime'
          ElementFont = efCSS
          HeightStyle = ssAuto
          HeightPercent = 100.000000000000000000
          HTML = 
            '<div style="z-index: 0; font-size: 11px; color: orange; line-hei' +
            'ght: 1;">5m<br />Time</div>'
          WidthPercent = 100.000000000000000000
        end
        object labelEditMode: TWebLabel
          Left = 10
          Top = 5
          Width = 49
          Height = 18
          Caption = 'labelZoom'
          ElementLabelClassName = 'text-white'
          ElementID = 'labelEditMode'
          ElementFont = efCSS
          HeightStyle = ssAuto
          HeightPercent = 100.000000000000000000
          HTML = 
            '<div style="font-size: 12px; color: white; font-weight:500;">Tri' +
            'm<span style="font-weight:400; color:gray;"> / Pitch</span></div' +
            '>'
          WidthPercent = 100.000000000000000000
        end
        object divZoomHolder: TWebHTMLDiv
          Left = 190
          Top = 0
          Width = 100
          Height = 56
          ElementID = 'divZoomHolder'
          ChildOrder = 1
          ElementFont = efCSS
          HTML.Strings = (
            
              '<div class="CusomTrackbar" title="Zoom" style="z-index: 10; posi' +
              'tion:absolute; transform:rotate(-20deg); left:5px; width:100px; ' +
              'height:20px; top:17px;">'
            
              '  <div class="rounded border bg-white" style="border-color: #000' +
              ' !important; position:absolute; width:86px; height:10px; top:5px' +
              '; left:7px"></div>'
            '  <div id="trackerZoom"'
            '          class="draggableTrackbar rounded-pill border border-2"'
            
              '          style="cursor:nesw-resize; border-color:#000 !importan' +
              't; background-color: pink; position:absolute; width: 20px; heigh' +
              't: 20px; top: 0px; '
            'left:0px;transform:translate(40px,0px)" '
            '          data-x="40">'
            '  </div>'
            '</div>')
          Role = ''
        end
        object divTimeHolder: TWebHTMLDiv
          Left = 266
          Top = 0
          Width = 100
          Height = 56
          ElementID = 'divTimeHolder'
          ChildOrder = 2
          ElementFont = efCSS
          HTML.Strings = (
            
              '<div class="CusomTrackbar" title="Zoom" style="position:absolute' +
              '; transform:rotate(-20deg); left:5px; width:100px; height:20px; ' +
              'top:17px;">'
            
              '  <div class="rounded border bg-white" style="border-color: #000' +
              ' !important; position:absolute; width:86px; height:10px; top:5px' +
              '; left:7px"></div>'
            '  <div id="trackerTime"'
            '          class="draggableTrackbar rounded-pill border border-2"'
            
              '          style="cursor:nesw-resize; border-color:#000 !importan' +
              't; background-color: orange; position:absolute; width: 20px; hei' +
              'ght: 20px; top: 0px; '
            'left:0px;transform:translate(40px,0px)" '
            '          data-x="40">'
            '  </div>'
            '</div>')
          Role = ''
        end
        object toggleEditMode: TWebToggleButton
          Left = 16
          Top = 25
          Width = 44
          Height = 22
          ElementClassName = 'rounded'
          ElementID = 'toggleEditMode'
          ElementFont = efCSS
          OnClick = toggleEditModeClick
        end
      end
    end
    object divMiddle: TWebHTMLDiv
      AlignWithMargins = True
      Left = 3
      Top = 130
      Width = 1086
      Height = 498
      Margins.Top = 0
      Margins.Bottom = 0
      ElementClassName = 'rounded-3 bg-black border border-secondary'
      ElementID = 'divMiddle'
      Align = alClient
      ChildOrder = 1
      ElementFont = efCSS
      Role = ''
    end
    object divTimeline: TWebHTMLDiv
      AlignWithMargins = True
      Left = 3
      Top = 92
      Width = 1086
      Height = 35
      Margins.Top = 0
      ElementClassName = 'rounded-3 bg-black border border-secondary'
      ElementID = 'divTimeline'
      Align = alTop
      ChildOrder = 1
      ElementFont = efCSS
      Role = ''
      object divTimelineLeft: TWebHTMLDiv
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 376
        Height = 29
        ElementClassName = 'rounded bg-dark'
        ElementID = 'divTimelineLeft'
        Align = alLeft
        ChildOrder = 1
        ElementFont = efCSS
        Role = ''
        object divElapsed: TWebLabel
          AlignWithMargins = True
          Left = 7
          Top = 1
          Width = 110
          Height = 28
          Margins.Left = 7
          Margins.Top = 1
          Margins.Right = 0
          Margins.Bottom = 0
          Align = alLeft
          Caption = '00:00:00.000'
          ElementLabelClassName = 'text-white'
          ElementID = 'divElapsed'
          ElementFont = efCSS
          HeightStyle = ssAuto
          HeightPercent = 100.000000000000000000
          Layout = tlCenter
          WidthPercent = 100.000000000000000000
        end
      end
      object divTimelineMiddle: TWebHTMLDiv
        AlignWithMargins = True
        Left = 382
        Top = 3
        Width = 322
        Height = 29
        Margins.Left = 0
        Margins.Right = 0
        ElementClassName = 'rounded bg-dark overflow-hidden'
        ElementID = 'divTimelineMiddle'
        Align = alClient
        ChildOrder = 1
        ElementFont = efCSS
        Role = ''
        object divTimelineChart: TWebHTMLDiv
          Left = 0
          Top = 0
          Width = 322
          Height = 29
          Margins.Left = 0
          Margins.Right = 0
          ElementID = 'divTimelineChart'
          Align = alClient
          ChildOrder = 1
          ElementFont = efCSS
          Role = ''
        end
      end
      object divTimelineRight: TWebHTMLDiv
        AlignWithMargins = True
        Left = 707
        Top = 3
        Width = 376
        Height = 29
        ElementClassName = 'rounded bg-dark'
        ElementID = 'divTimelineRight'
        Align = alRight
        ChildOrder = 2
        ElementFont = efCSS
        Role = ''
        object divRemaining: TWebLabel
          AlignWithMargins = True
          Left = 264
          Top = 1
          Width = 104
          Height = 28
          Margins.Left = 0
          Margins.Top = 1
          Margins.Right = 8
          Margins.Bottom = 0
          Align = alRight
          Alignment = taRightJustify
          Caption = '00:00:00.000'
          ElementLabelClassName = 'text-white'
          ElementID = 'divRemaining'
          ElementFont = efCSS
          HeightStyle = ssAuto
          HeightPercent = 100.000000000000000000
          Layout = tlCenter
          WidthPercent = 100.000000000000000000
        end
      end
    end
  end
  object divCursor: TWebHTMLDiv
    Left = 384
    Top = 94
    Width = 20
    Height = 41
    ElementID = 'divCursor'
    ChildOrder = 1
    ElementFont = efCSS
    HTML.Strings = (
      
        '<div style="position:absolute; z-index: 999; height: 100%;  colo' +
        'r: silver;" class="draggableCursor">'
      '  <i class="fa-solid fa-droplet fa-rotate-180"></i>'
      
        '  <div style="position:absolute; background-color:white; opacity' +
        ':0.25; width: 2px; top:10px; left:5px; height:100%;"></div>'
      '</div>')
    Role = ''
  end
  object WebOpenDialogTracks: TWebOpenDialog
    Accept = 'audio/*'
    MultiFile = True
    OnGetFileAsArrayBuffer = WebOpenDialogTracksGetFileAsArrayBuffer
    Left = 57
    Top = 579
  end
  object tmrCursor: TWebTimer
    Enabled = False
    Interval = 100
    OnTimer = tmrCursorTimer
    Left = 600
    Top = 152
  end
end
