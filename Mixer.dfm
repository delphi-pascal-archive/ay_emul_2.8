object Form2: TForm2
  Left = 183
  Top = 75
  BorderStyle = bsDialog
  Caption = 'Mixer'
  ClientHeight = 486
  ClientWidth = 503
  Color = clBtnFace
  DefaultMonitor = dmDesktop
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnHide = FormHide
  PixelsPerInch = 96
  TextHeight = 13
  object MixerTabSheet: TPageControl
    Left = 0
    Top = 0
    Width = 503
    Height = 449
    ActivePage = AYEmuSheet
    Align = alTop
    TabOrder = 0
    object AYEmuSheet: TTabSheet
      Caption = 'AY Emulation'
      object KUsil: TGroupBox
        Left = 4
        Top = 1
        Width = 314
        Height = 264
        Caption = 'Channels amplification'
        TabOrder = 0
        object Bevel1: TBevel
          Left = 37
          Top = 84
          Width = 10
          Height = 2
          Shape = bsBottomLine
        end
        object Bevel3: TBevel
          Left = 47
          Top = 96
          Width = 10
          Height = 2
          Shape = bsBottomLine
        end
        object Bevel4: TBevel
          Left = 47
          Top = 72
          Width = 10
          Height = 2
          Shape = bsTopLine
        end
        object Bevel2: TBevel
          Left = 47
          Top = 73
          Width = 2
          Height = 23
          Shape = bsLeftLine
        end
        object Bevel18: TBevel
          Left = 47
          Top = 24
          Width = 10
          Height = 2
          Shape = bsTopLine
        end
        object Bevel19: TBevel
          Left = 47
          Top = 48
          Width = 10
          Height = 2
          Shape = bsBottomLine
        end
        object Bevel20: TBevel
          Left = 37
          Top = 36
          Width = 10
          Height = 2
          Shape = bsBottomLine
        end
        object Bevel17: TBevel
          Left = 47
          Top = 25
          Width = 2
          Height = 23
          Shape = bsLeftLine
        end
        object Bevel21: TBevel
          Left = 47
          Top = 144
          Width = 10
          Height = 2
          Shape = bsBottomLine
        end
        object Bevel23: TBevel
          Left = 37
          Top = 132
          Width = 10
          Height = 2
          Shape = bsBottomLine
        end
        object Bevel24: TBevel
          Left = 47
          Top = 120
          Width = 10
          Height = 2
          Shape = bsTopLine
        end
        object Bevel22: TBevel
          Left = 47
          Top = 121
          Width = 2
          Height = 23
          Shape = bsLeftLine
        end
        object Label8: TLabel
          Left = 16
          Top = 180
          Width = 73
          Height = 24
          Caption = 'Preamp'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -19
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Label9: TLabel
          Left = 16
          Top = 155
          Width = 69
          Height = 24
          Caption = 'Beeper'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -19
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Label11: TLabel
          Left = 16
          Top = 24
          Width = 15
          Height = 24
          Caption = 'A'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -19
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Label14: TLabel
          Left = 16
          Top = 72
          Width = 14
          Height = 24
          Caption = 'B'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -19
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Label15: TLabel
          Left = 16
          Top = 120
          Width = 15
          Height = 24
          Caption = 'C'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -19
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Label16: TLabel
          Left = 60
          Top = 16
          Width = 26
          Height = 16
          Caption = 'Left'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Label17: TLabel
          Left = 60
          Top = 40
          Width = 37
          Height = 16
          Caption = 'Right'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Label18: TLabel
          Left = 60
          Top = 64
          Width = 26
          Height = 16
          Caption = 'Left'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Label19: TLabel
          Left = 60
          Top = 88
          Width = 37
          Height = 16
          Caption = 'Right'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Label20: TLabel
          Left = 60
          Top = 112
          Width = 26
          Height = 16
          Caption = 'Left'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Label21: TLabel
          Left = 60
          Top = 136
          Width = 37
          Height = 16
          Caption = 'Right'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object TrackBar1: TTrackBar
          Left = 101
          Top = 16
          Width = 150
          Height = 24
          Max = 255
          Frequency = 15
          Position = 255
          TabOrder = 0
          ThumbLength = 15
          OnChange = TrackBar1Change
        end
        object TrackBar2: TTrackBar
          Left = 101
          Top = 40
          Width = 150
          Height = 24
          Max = 255
          Frequency = 15
          Position = 13
          TabOrder = 1
          ThumbLength = 15
          OnChange = TrackBar2Change
        end
        object TrackBar3: TTrackBar
          Left = 101
          Top = 64
          Width = 150
          Height = 24
          Max = 255
          Frequency = 15
          Position = 170
          TabOrder = 2
          ThumbLength = 15
          OnChange = TrackBar3Change
        end
        object TrackBar4: TTrackBar
          Left = 101
          Top = 88
          Width = 150
          Height = 24
          Max = 255
          Frequency = 15
          Position = 170
          TabOrder = 3
          ThumbLength = 15
          OnChange = TrackBar4Change
        end
        object TrackBar5: TTrackBar
          Left = 101
          Top = 112
          Width = 150
          Height = 24
          Max = 255
          Frequency = 15
          Position = 13
          TabOrder = 4
          ThumbLength = 15
          OnChange = TrackBar5Change
        end
        object TrackBar6: TTrackBar
          Left = 101
          Top = 136
          Width = 150
          Height = 24
          Max = 255
          Frequency = 15
          Position = 255
          TabOrder = 5
          ThumbLength = 15
          OnChange = TrackBar6Change
        end
        object Edit1: TEdit
          Left = 253
          Top = 16
          Width = 25
          Height = 21
          TabOrder = 6
          OnExit = Edit1Exit
        end
        object Edit2: TEdit
          Left = 253
          Top = 40
          Width = 25
          Height = 21
          TabOrder = 7
          OnExit = Edit2Exit
        end
        object Edit6: TEdit
          Left = 253
          Top = 136
          Width = 25
          Height = 21
          TabOrder = 11
          OnExit = Edit6Exit
        end
        object Edit5: TEdit
          Left = 253
          Top = 112
          Width = 25
          Height = 21
          TabOrder = 10
          OnExit = Edit5Exit
        end
        object Edit3: TEdit
          Left = 253
          Top = 64
          Width = 25
          Height = 21
          TabOrder = 8
          OnExit = Edit3Exit
        end
        object Edit4: TEdit
          Left = 253
          Top = 88
          Width = 25
          Height = 21
          TabOrder = 9
          OnExit = Edit4Exit
        end
        object CheckBox1: TCheckBox
          Left = 10
          Top = 232
          Width = 105
          Height = 17
          Caption = 'Get from list'
          Checked = True
          State = cbChecked
          TabOrder = 18
        end
        object ComboBox1: TComboBox
          Left = 120
          Top = 230
          Width = 185
          Height = 21
          Style = csDropDownList
          DropDownCount = 13
          ItemHeight = 13
          TabOrder = 19
          OnChange = ComboBox1Change
          Items.Strings = (
            'Mono'
            'AY ABC Stereo'
            'AY ACB Stereo'
            'AY BAC Stereo'
            'AY BCA Stereo'
            'AY CAB Stereo'
            'AY CBA Stereo'
            'YM ABC Stereo'
            'YM ACB Stereo'
            'YM BAC Stereo'
            'YM BCA Stereo'
            'YM CAB Stereo'
            'YM CBA Stereo')
        end
        object Edit12: TEdit
          Left = 280
          Top = 16
          Width = 25
          Height = 21
          TabStop = False
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 12
        end
        object Edit13: TEdit
          Left = 280
          Top = 40
          Width = 25
          Height = 21
          TabStop = False
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 13
        end
        object Edit15: TEdit
          Left = 280
          Top = 88
          Width = 25
          Height = 21
          TabStop = False
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 15
        end
        object Edit16: TEdit
          Left = 280
          Top = 112
          Width = 25
          Height = 21
          TabStop = False
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 16
        end
        object Edit17: TEdit
          Left = 280
          Top = 136
          Width = 25
          Height = 21
          TabStop = False
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 17
        end
        object Edit14: TEdit
          Left = 280
          Top = 64
          Width = 25
          Height = 21
          TabStop = False
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 14
        end
        object TrackBar7: TTrackBar
          Left = 101
          Top = 160
          Width = 150
          Height = 24
          Max = 255
          Frequency = 15
          Position = 255
          TabOrder = 20
          ThumbLength = 15
          OnChange = TrackBar7Change
        end
        object Edit20: TEdit
          Left = 253
          Top = 160
          Width = 25
          Height = 21
          TabOrder = 21
          OnExit = Edit20Exit
        end
        object TrackBar13: TTrackBar
          Left = 101
          Top = 184
          Width = 150
          Height = 24
          Max = 255
          Frequency = 15
          Position = 255
          TabOrder = 22
          ThumbLength = 15
          OnChange = TrackBar13Change
        end
        object Edit30: TEdit
          Left = 253
          Top = 184
          Width = 25
          Height = 21
          TabOrder = 23
          OnExit = Edit30Exit
        end
      end
      object GroupBox1: TGroupBox
        Left = 4
        Top = 265
        Width = 125
        Height = 87
        Caption = 'Chip type'
        TabOrder = 1
        object RadioButton1: TRadioButton
          Left = 8
          Top = 22
          Width = 89
          Height = 17
          Caption = 'AY-3-8910/12'
          TabOrder = 0
          OnClick = RadioButton1Click
        end
        object RadioButton2: TRadioButton
          Left = 8
          Top = 41
          Width = 89
          Height = 17
          Caption = 'YM2149F'
          Checked = True
          TabOrder = 1
          TabStop = True
          OnClick = RadioButton2Click
        end
        object CheckBox2: TCheckBox
          Left = 10
          Top = 63
          Width = 105
          Height = 17
          Caption = 'Get from list'
          Checked = True
          State = cbChecked
          TabOrder = 2
        end
        object CheckBox4: TCheckBox
          Left = 101
          Top = 21
          Width = 17
          Height = 17
          TabStop = False
          Color = clBtnFace
          Enabled = False
          ParentColor = False
          TabOrder = 3
        end
        object CheckBox5: TCheckBox
          Left = 101
          Top = 40
          Width = 17
          Height = 17
          TabStop = False
          Caption = 'CheckBox5'
          Color = clBtnFace
          Enabled = False
          ParentColor = False
          TabOrder = 4
        end
      end
      object GroupBox2: TGroupBox
        Left = 323
        Top = 1
        Width = 169
        Height = 176
        Caption = 'Sound chip frequency'
        TabOrder = 2
        object RadioButton3: TRadioButton
          Left = 11
          Top = 21
          Width = 94
          Height = 17
          Caption = 'ZX Spectrum'
          Checked = True
          TabOrder = 0
          TabStop = True
          OnClick = RadioButton3Click
        end
        object RadioButton4: TRadioButton
          Left = 11
          Top = 42
          Width = 94
          Height = 17
          Caption = 'Pentagon 128K'
          TabOrder = 1
          OnClick = RadioButton4Click
        end
        object RadioButton5: TRadioButton
          Left = 11
          Top = 63
          Width = 94
          Height = 17
          Caption = 'Atari ST'
          TabOrder = 2
          OnClick = RadioButton5Click
        end
        object RadioButton6: TRadioButton
          Left = 11
          Top = 84
          Width = 94
          Height = 17
          Caption = 'Amstrad CPC'
          TabOrder = 3
          OnClick = RadioButton6Click
        end
        object RadioButton7: TRadioButton
          Left = 11
          Top = 105
          Width = 94
          Height = 17
          Caption = 'Another'
          TabOrder = 4
          OnClick = RadioButton7Click
        end
        object CheckBox3: TCheckBox
          Left = 10
          Top = 151
          Width = 103
          Height = 17
          Caption = 'Get from list'
          Checked = True
          State = cbChecked
          TabOrder = 11
        end
        object Edit7: TEdit
          Left = 110
          Top = 20
          Width = 50
          Height = 21
          TabStop = False
          ReadOnly = True
          TabOrder = 5
          Text = '1773400'
        end
        object Edit8: TEdit
          Left = 110
          Top = 41
          Width = 50
          Height = 21
          TabStop = False
          ReadOnly = True
          TabOrder = 6
          Text = '1750000'
        end
        object Edit9: TEdit
          Left = 110
          Top = 62
          Width = 50
          Height = 21
          TabStop = False
          ReadOnly = True
          TabOrder = 7
          Text = '2000000'
        end
        object Edit10: TEdit
          Left = 110
          Top = 83
          Width = 50
          Height = 21
          TabStop = False
          ReadOnly = True
          TabOrder = 8
          Text = '1000000'
        end
        object Edit11: TEdit
          Left = 110
          Top = 104
          Width = 50
          Height = 21
          TabOrder = 9
          OnExit = Edit11Exit
        end
        object Edit18: TEdit
          Left = 110
          Top = 125
          Width = 50
          Height = 21
          TabStop = False
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 10
        end
      end
      object GroupBox6: TGroupBox
        Left = 132
        Top = 265
        Width = 186
        Height = 64
        Caption = 'OUT, ZXAY, AY, AYM'
        TabOrder = 3
        object Label1: TLabel
          Left = 9
          Top = 18
          Width = 84
          Height = 13
          Caption = 'TStates per frame'
        end
        object Label7: TLabel
          Left = 9
          Top = 39
          Width = 68
          Height = 13
          Caption = 'Interrupt offset'
        end
        object Edit19: TEdit
          Left = 130
          Top = 15
          Width = 45
          Height = 21
          TabOrder = 0
          OnExit = Edit19Exit
        end
        object FTact: TEdit
          Left = 130
          Top = 38
          Width = 45
          Height = 21
          TabOrder = 1
          OnExit = FTactExit
        end
      end
      object GroupBox7: TGroupBox
        Left = 323
        Top = 178
        Width = 169
        Height = 131
        Caption = 'Interrupt frequency'
        TabOrder = 4
        object RadioButton15: TRadioButton
          Left = 8
          Top = 17
          Width = 88
          Height = 17
          Caption = 'ZX Spectrum'
          Checked = True
          TabOrder = 0
          TabStop = True
          OnClick = RadioButton15Click
        end
        object Edit21: TEdit
          Left = 107
          Top = 15
          Width = 53
          Height = 21
          TabStop = False
          ReadOnly = True
          TabOrder = 3
        end
        object RadioButton16: TRadioButton
          Left = 8
          Top = 57
          Width = 88
          Height = 17
          Caption = 'Another'
          TabOrder = 2
          OnClick = RadioButton16Click
        end
        object Edit22: TEdit
          Left = 107
          Top = 57
          Width = 53
          Height = 21
          TabOrder = 5
          OnExit = Edit22Exit
        end
        object CheckBox9: TCheckBox
          Left = 10
          Top = 104
          Width = 105
          Height = 18
          Caption = 'Get from list'
          Checked = True
          State = cbChecked
          TabOrder = 7
        end
        object Edit23: TEdit
          Left = 107
          Top = 78
          Width = 53
          Height = 21
          TabStop = False
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 6
        end
        object RadioButton17: TRadioButton
          Left = 8
          Top = 37
          Width = 97
          Height = 17
          Caption = 'Pentagon 128K'
          TabOrder = 1
          OnClick = RadioButton17Click
        end
        object Edit24: TEdit
          Left = 107
          Top = 36
          Width = 53
          Height = 21
          TabStop = False
          ReadOnly = True
          TabOrder = 4
        end
      end
      object GroupBox8: TGroupBox
        Left = 323
        Top = 311
        Width = 169
        Height = 105
        Caption = 'YM5, YM6 (MFP Timer)'
        TabOrder = 5
        object RadioButton18: TRadioButton
          Left = 8
          Top = 17
          Width = 97
          Height = 17
          Caption = 'AY/YM x 16/13'
          Checked = True
          TabOrder = 0
          TabStop = True
          OnClick = RadioButton18Click
        end
        object RadioButton19: TRadioButton
          Left = 8
          Top = 37
          Width = 81
          Height = 17
          Caption = 'Atari ST'
          TabOrder = 1
          OnClick = RadioButton19Click
        end
        object RadioButton20: TRadioButton
          Left = 8
          Top = 57
          Width = 89
          Height = 17
          Caption = 'Another'
          TabOrder = 2
          OnClick = RadioButton20Click
        end
        object Edit25: TEdit
          Left = 107
          Top = 57
          Width = 53
          Height = 21
          TabOrder = 4
          OnExit = Edit25Exit
        end
        object Edit26: TEdit
          Left = 107
          Top = 78
          Width = 53
          Height = 21
          TabStop = False
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 5
        end
        object Edit27: TEdit
          Left = 107
          Top = 36
          Width = 53
          Height = 21
          TabStop = False
          ReadOnly = True
          TabOrder = 3
          Text = '2457600'
        end
      end
      object GroupBox9: TGroupBox
        Left = 132
        Top = 329
        Width = 186
        Height = 87
        Caption = 'Z80 frequency'
        TabOrder = 6
        object RadioButton21: TRadioButton
          Left = 11
          Top = 21
          Width = 94
          Height = 17
          Caption = 'ZX Spectrum'
          Checked = True
          TabOrder = 0
          TabStop = True
          OnClick = RadioButton21Click
        end
        object RadioButton22: TRadioButton
          Left = 11
          Top = 42
          Width = 94
          Height = 17
          Caption = 'Pentagon 128K'
          TabOrder = 1
          OnClick = RadioButton22Click
        end
        object RadioButton25: TRadioButton
          Left = 11
          Top = 63
          Width = 94
          Height = 17
          Caption = 'Another'
          TabOrder = 2
          OnClick = RadioButton25Click
        end
        object Edit28: TEdit
          Left = 109
          Top = 20
          Width = 65
          Height = 21
          TabStop = False
          ReadOnly = True
          TabOrder = 3
          Text = '3494400'
        end
        object Edit29: TEdit
          Left = 109
          Top = 41
          Width = 65
          Height = 21
          TabStop = False
          ReadOnly = True
          TabOrder = 4
          Text = '3500000'
        end
        object Edit32: TEdit
          Left = 109
          Top = 62
          Width = 65
          Height = 21
          TabOrder = 5
          OnExit = Edit32Exit
        end
      end
      object GroupBox12: TGroupBox
        Left = 4
        Top = 354
        Width = 125
        Height = 62
        Caption = 'Optimization'
        TabOrder = 7
        object Label12: TLabel
          Left = 11
          Top = 45
          Width = 58
          Height = 13
          Caption = 'Filter quality:'
        end
        object Label13: TLabel
          Left = 72
          Top = 44
          Width = 12
          Height = 13
          Caption = '32'
        end
        object RadioButton26: TRadioButton
          Left = 9
          Top = 29
          Width = 96
          Height = 17
          Caption = 'for quality'
          Checked = True
          TabOrder = 0
          TabStop = True
          OnClick = RadioButton26Click
        end
        object RadioButton28: TRadioButton
          Left = 9
          Top = 13
          Width = 96
          Height = 17
          Caption = 'for performance'
          TabOrder = 1
          OnClick = RadioButton28Click
        end
        object TrackBar14: TTrackBar
          Left = 104
          Top = 8
          Width = 16
          Height = 52
          Max = 6
          Orientation = trVertical
          Position = 2
          TabOrder = 2
          ThumbLength = 10
          OnChange = TrackBar14Change
        end
      end
    end
    object WOSheet: TTabSheet
      Caption = 'WaveOut'
      ImageIndex = 1
      object SpeedButton2: TSpeedButton
        Left = 408
        Top = 360
        Width = 81
        Height = 49
        Caption = 'Stop playing'
        OnClick = SpeedButton2Click
      end
      object GroupBox3: TGroupBox
        Left = 31
        Top = 8
        Width = 134
        Height = 137
        Caption = 'Sample rate'
        TabOrder = 0
        object SpeedButton1: TSpeedButton
          Left = 24
          Top = 116
          Width = 85
          Height = 17
          Caption = 'AY / 8'
          OnClick = SpeedButton1Click
        end
        object RadioButton23: TRadioButton
          Left = 11
          Top = 30
          Width = 57
          Height = 17
          Caption = '48000'
          TabOrder = 1
          OnClick = RadioButton23Click
        end
        object StaticText14: TStaticText
          Left = 72
          Top = 31
          Width = 17
          Height = 17
          Caption = 'Hz'
          TabOrder = 10
        end
        object RadioButton8: TRadioButton
          Left = 11
          Top = 46
          Width = 57
          Height = 17
          Caption = '44100'
          Checked = True
          TabOrder = 2
          TabStop = True
          OnClick = RadioButton8Click
        end
        object RadioButton9: TRadioButton
          Left = 11
          Top = 62
          Width = 57
          Height = 17
          Caption = '22050'
          TabOrder = 3
          OnClick = RadioButton9Click
        end
        object RadioButton10: TRadioButton
          Left = 11
          Top = 78
          Width = 57
          Height = 17
          Caption = '11025'
          TabOrder = 4
          OnClick = RadioButton10Click
        end
        object StaticText10: TStaticText
          Left = 72
          Top = 47
          Width = 17
          Height = 17
          Caption = 'Hz'
          TabOrder = 7
        end
        object StaticText11: TStaticText
          Left = 72
          Top = 63
          Width = 17
          Height = 17
          Caption = 'Hz'
          TabOrder = 8
        end
        object StaticText12: TStaticText
          Left = 72
          Top = 79
          Width = 17
          Height = 17
          Caption = 'Hz'
          TabOrder = 9
        end
        object RadioButton24: TRadioButton
          Left = 11
          Top = 14
          Width = 57
          Height = 17
          Caption = '96000'
          TabOrder = 0
          OnClick = RadioButton24Click
        end
        object StaticText15: TStaticText
          Left = 72
          Top = 16
          Width = 17
          Height = 17
          Caption = 'Hz'
          TabOrder = 11
        end
        object RadioButton27: TRadioButton
          Left = 11
          Top = 95
          Width = 57
          Height = 17
          Caption = 'Another'
          TabOrder = 5
          OnClick = RadioButton27Click
        end
        object Edit31: TEdit
          Left = 72
          Top = 95
          Width = 49
          Height = 17
          AutoSize = False
          TabOrder = 6
          OnExit = Edit31Exit
        end
      end
      object GroupBox5: TGroupBox
        Left = 172
        Top = 65
        Width = 122
        Height = 80
        Caption = 'Channels'
        TabOrder = 1
        object RadioButton13: TRadioButton
          Left = 11
          Top = 21
          Width = 57
          Height = 17
          Caption = 'Stereo'
          Checked = True
          TabOrder = 0
          TabStop = True
          OnClick = RadioButton13Click
        end
        object RadioButton14: TRadioButton
          Left = 11
          Top = 37
          Width = 57
          Height = 17
          Caption = 'Mono'
          TabOrder = 1
          OnClick = RadioButton14Click
        end
        object CheckBox6: TCheckBox
          Left = 71
          Top = 37
          Width = 17
          Height = 17
          TabStop = False
          Caption = 'CheckBox5'
          Color = clBtnFace
          Enabled = False
          ParentColor = False
          TabOrder = 3
        end
        object CheckBox7: TCheckBox
          Left = 71
          Top = 21
          Width = 17
          Height = 17
          TabStop = False
          Caption = 'CheckBox7'
          Color = clBtnFace
          Enabled = False
          ParentColor = False
          TabOrder = 4
        end
        object CheckBox8: TCheckBox
          Left = 10
          Top = 57
          Width = 105
          Height = 17
          Caption = 'Get from list'
          Checked = True
          State = cbChecked
          TabOrder = 2
        end
      end
      object GroupBox4: TGroupBox
        Left = 172
        Top = 8
        Width = 122
        Height = 55
        Caption = 'Bit rate'
        TabOrder = 2
        object RadioButton11: TRadioButton
          Left = 12
          Top = 17
          Width = 57
          Height = 17
          Caption = '16 bit'
          Checked = True
          TabOrder = 0
          TabStop = True
          OnClick = RadioButton11Click
        end
        object RadioButton12: TRadioButton
          Left = 12
          Top = 32
          Width = 57
          Height = 17
          Caption = '8 bit'
          TabOrder = 1
          OnClick = RadioButton12Click
        end
      end
      object Buff: TGroupBox
        Left = 302
        Top = 8
        Width = 153
        Height = 137
        Caption = 'Buffers'
        TabOrder = 3
        object LbLen: TLabel
          Left = 72
          Top = 16
          Width = 34
          Height = 13
          Caption = '726 ms'
        end
        object LbNum: TLabel
          Left = 96
          Top = 64
          Width = 6
          Height = 13
          Caption = '3'
        end
        object Label4: TLabel
          Left = 8
          Top = 115
          Width = 56
          Height = 13
          Caption = 'Total length'
        end
        object LBTot: TLabel
          Left = 69
          Top = 115
          Width = 40
          Height = 13
          Caption = '2178 ms'
        end
        object Label5: TLabel
          Left = 8
          Top = 16
          Width = 60
          Height = 13
          Caption = 'Buffer length'
        end
        object Label6: TLabel
          Left = 8
          Top = 64
          Width = 84
          Height = 13
          Caption = 'Number of buffers'
        end
        object TrackBar8: TTrackBar
          Left = 2
          Top = 32
          Width = 149
          Height = 33
          Hint = 'Length of one buffer'
          Max = 2000
          Min = 5
          PageSize = 1
          Frequency = 100
          Position = 726
          TabOrder = 0
          OnChange = TrackBar8Change
        end
        object TrackBar9: TTrackBar
          Left = 2
          Top = 80
          Width = 149
          Height = 33
          Hint = 'Number of buffers'
          Min = 2
          PageSize = 1
          Position = 3
          TabOrder = 1
          OnChange = TrackBar9Change
        end
      end
      object GroupBox10: TGroupBox
        Left = 144
        Top = 152
        Width = 177
        Height = 57
        Caption = 'Device'
        TabOrder = 4
        object ComboBox2: TComboBox
          Left = 16
          Top = 24
          Width = 145
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 0
          OnChange = ComboBox2Change
          Items.Strings = (
            'Wave mapper')
        end
      end
    end
    object VolumeSheet: TTabSheet
      Caption = 'Global Volume Control'
      ImageIndex = 3
      object Label3: TLabel
        Left = 8
        Top = 8
        Width = 109
        Height = 13
        Caption = 'Current volume control:'
      end
      object Button3: TButton
        Left = 120
        Top = 64
        Width = 105
        Height = 25
        Caption = 'Select'
        TabOrder = 0
        OnClick = Button3Click
      end
      object Button4: TButton
        Left = 264
        Top = 64
        Width = 97
        Height = 25
        Caption = 'Autodetect'
        TabOrder = 1
        OnClick = Button4Click
      end
      object Edit33: TEdit
        Left = 8
        Top = 24
        Width = 481
        Height = 21
        Color = clBtnFace
        ParentShowHint = False
        ReadOnly = True
        ShowHint = False
        TabOrder = 2
      end
      object CheckBox10: TCheckBox
        Left = 8
        Top = 104
        Width = 113
        Height = 17
        Caption = 'Linear scale (as is)'
        TabOrder = 3
        OnClick = CheckBox10Click
      end
      object CheckBox39: TCheckBox
        Left = 8
        Top = 120
        Width = 123
        Height = 17
        Caption = 'Save volume position'
        TabOrder = 4
        OnClick = CheckBox39Click
      end
    end
    object BASSSheet: TTabSheet
      Caption = 'BASS.DLL v2.1'
      ImageIndex = 2
      object GroupBox11: TGroupBox
        Left = 6
        Top = 8
        Width = 155
        Height = 121
        Caption = 'Visualization'
        TabOrder = 0
        object FFTTyp: TLabel
          Left = 65
          Top = 16
          Width = 64
          Height = 13
          Caption = 'high (slowest)'
        end
        object Label10: TLabel
          Left = 8
          Top = 16
          Width = 55
          Height = 13
          Caption = 'FFT quality:'
        end
        object Label2: TLabel
          Left = 8
          Top = 64
          Width = 93
          Height = 13
          Caption = 'AmpMin/AmpMax ='
        end
        object aminmax: TLabel
          Left = 105
          Top = 64
          Width = 27
          Height = 13
          Caption = '0.003'
        end
        object TrackBar11: TTrackBar
          Left = 2
          Top = 32
          Width = 149
          Height = 33
          Hint = 'Number of buffers'
          Max = 3
          PageSize = 1
          Position = 3
          TabOrder = 0
          OnChange = TrackBar11Change
        end
        object TrackBar12: TTrackBar
          Left = 2
          Top = 80
          Width = 149
          Height = 33
          Hint = 'Number of buffers'
          Max = 1000
          Min = 1
          PageSize = 10
          Frequency = 100
          Position = 30
          TabOrder = 1
          OnChange = TrackBar12Change
        end
      end
    end
  end
  object Button1: TButton
    Left = 158
    Top = 456
    Width = 90
    Height = 25
    Caption = 'Restore'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 264
    Top = 456
    Width = 90
    Height = 25
    Cancel = True
    Caption = 'Close'
    Default = True
    TabOrder = 2
    OnClick = Button2Click
  end
end
