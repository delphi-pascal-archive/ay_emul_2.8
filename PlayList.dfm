object Form3: TForm3
  Left = 98
  Top = 79
  Width = 491
  Height = 344
  Caption = 'Playlist'
  Color = clBtnFace
  Constraints.MinHeight = 84
  Constraints.MinWidth = 491
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnHide = FormHide
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 284
    Width = 483
    Height = 26
    Align = alBottom
    BevelOuter = bvNone
    FullRepaint = False
    TabOrder = 0
    object SpeedButton1: TSpeedButton
      Left = 5
      Top = 3
      Width = 89
      Height = 23
      Caption = 'Add items'
      OnClick = SpeedButton1Click
    end
    object SpeedButton2: TSpeedButton
      Left = 94
      Top = 3
      Width = 89
      Height = 23
      Caption = 'Clear list'
      OnClick = SpeedButton2Click
    end
    object SpeedButton3: TSpeedButton
      Left = 183
      Top = 3
      Width = 89
      Height = 23
      Caption = 'Save list'
      OnClick = SpeedButton3Click
    end
    object SpeedButton4: TSpeedButton
      Left = 272
      Top = 3
      Width = 89
      Height = 23
      Caption = 'List tools'
      OnClick = SpeedButton4Click
    end
    object Label1: TLabel
      Left = 416
      Top = 13
      Width = 63
      Height = 13
      Alignment = taCenter
      AutoSize = False
      Caption = '0:00'
      OnMouseDown = Label1MouseDown
    end
    object DirectionButton: TSpeedButton
      Left = 361
      Top = 3
      Width = 25
      Height = 23
      OnClick = DirectionButtonClick
    end
    object LoopListButton: TSpeedButton
      Left = 386
      Top = 3
      Width = 24
      Height = 23
      AllowAllUp = True
      GroupIndex = 1
      Glyph.Data = {
        7E000000424D7E000000000000003E0000002800000010000000100000000100
        0100000000004000000010170000101700000200000000000000FFFFFF000000
        000000000000000000000000000003C0000017E000001E3000001C1800001E00
        000000780000183800000C78000007E8000003C0000000000000000000000000
        0000}
      OnClick = LoopListButtonClick
    end
    object Label2: TLabel
      Left = 416
      Top = 0
      Width = 63
      Height = 13
      Alignment = taCenter
      AutoSize = False
      Caption = '0'
    end
  end
  object PopupMenu1: TPopupMenu
    OnPopup = PopupMenu1Popup
    Left = 48
    Top = 240
    object N1: TMenuItem
      Caption = 'Item adjusting...'
      OnClick = N1Click
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object WAV1: TMenuItem
      Caption = 'Convert to WAV...'
      OnClick = WAV1Click
    end
    object PSG2: TMenuItem
      Caption = 'Convert to ZXAY...'
      OnClick = PSG2Click
    end
    object VTX1: TMenuItem
      Caption = 'Convert to VTX...'
      OnClick = VTX1Click
    end
    object YM1: TMenuItem
      Caption = 'Convert to YM6...'
      OnClick = YM1Click
    end
    object PSG1: TMenuItem
      Caption = 'Convert to PSG...'
      OnClick = PSG1Click
    end
    object N2: TMenuItem
      Caption = 'Save as...'
      OnClick = N2Click
    end
  end
  object ImageList1: TImageList
    Left = 128
    Top = 240
    Bitmap = {
      494C010104000900040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000003000000001001800000000000024
      000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFE1FFFFE1FFFFE1FFFFFFFFFFFFFFFFFFFFFFFFFFFFB5CE
      CEB5CECEB5CECEB5CECEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FF849C9C849C9C849C9CFFFFFFFFFFFFB5CECEB5CECEB5CECEFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFB5CECEB5CECEB5CECEB5CECEB5CECEFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF849C9CFFFFFFCECECE7B7B7B1018
      180000000000000000001018184A4A4AFFFFFFCECECECECECECECECE9C9C9C31
      31310000000000000000000000003131319C9C9CCECECEBDBDBD101818000000
      000000313131313131000000000000000000101818313131CECECE7373730000
      001018184A4A4A6363634A4A4A313131849C9CCECECECECECECECECE9C9C9C42
      4242000000000000000000000000000000000000000000000000B5CECEFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCECECECECECECECECECECECECECE
      CECECECECECECECECECECECECECECECECECECECECECECECECEB5CECEB5CECEFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFB5CECE
      CECECECECECECECECECECECECECECECECECECECECECECECECECECEB5CECEFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFCECECECECECE31313100000000000000000000
      0000000000313131849C9C4A4A4A1018180000000000003131319C9C9CCECECE
      CECECECECECECECECEB5CECE849C9C000000FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFF000000E1FFFFE1FFFF849C9CCECECECECECECECECECECE
      CE4A4A4A0000004A4A4ACECECECECECEB5CECECECECECECECECECECECECECECE
      CECEB5B5B5000000000000B5B5B5CECECECECECECECECE636363000000000000
      849C9CFFFFFFFFFFFF7B7B7B000000101818CECECECECECECECECE6363634242
      42FFFFFFFFFFFFFFFFFFCECECEBDBDBD101818636363CECECECECECECECECEBD
      BDBD0000000000009C9C9CCECECECECECECECECE9C9C9C000000B5CECEFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCECECECECECECECECECECECECECE
      CECECECECECECECECECECECECECECECECECECECECECECECECECECECECECECECE
      CECEB5CECEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCECECECECECE
      CECECECECECECECECECECECECECECECECECECECECECECECECECECECECECECECE
      CEB5CECEFFFFFFFFFFFFFFFFFFCECECECECECECECECECECECE42424200000010
      1818BDBDBDFFFFFFFFFFFFFFFFFFFFFFFF1018187B7B7BCECECECECECECECECE
      CECECECECECECECECEBDBDBD101818000000FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFF000000E1FFFFE1FFFF849C9CCECECECECECECECECECECE
      CE636363000000636363CECECECECECECECECECECECECECECECECECECECECECE
      CECECECECE000000000000CECECECECECECECECE9C9C9C0000000000009C9C9C
      FFFFFFFFFFFFFFFFFF849C9C000000313131CECECECECECECECECE7B7B7B9C9C
      9CFFFFFFFFFFFFB5CECECECECECECECE7B7B7B000000B5B5B5CECECECECECECE
      CECE000000000000CECECECECECECECECECECECECECECE4A4A4A849C9CFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCECECECECECECECECECECECECECE
      CECECECECECECECECECECECECECECECECECECECECECECECECECECECECECECECE
      CECECECECECECECEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCECECECECECECECECE
      CECECECECECECECECECECECECECECECECECECECECECECECECECECECECECECECE
      CECECECEFFFFFFFFFFFFFFFFFFCECECECECECECECECECECECE63636300000031
      3131B5CECEFFFFFFFFFFFFFFFFFFFFFFFF3131319C9C9CCECECECECECECECECE
      CECECECECECECECECE101818000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFE1FFFFE1FFFF0000009C9C9CCECECECECECECECECECECE
      CE636363000000636363CECECECECECECECECECECECECECECECECECECECECECE
      CECECECECE000000000000CECECECECECEBDBDBD000000000000636363CECECE
      FFFFFFFFFFFFFFFFFF849C9C000000313131CECECECECECECECECEBDBDBDBDBD
      BDFFFFFFFFFFFFCECECECECECECECECE9C9C9C000000636363CECECECECECECE
      CECE000000000000CECECECECECECECECECECECECECECECECECEB5CECEFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCECECECECECECECECECECECECECE
      CECECECECECECECECECECECECECECECECECECECECECECECECECECECECECECECE
      CECECECECECECECEB5CECEFFFFFFFFFFFFFFFFFFB5CECECECECECECECECECECE
      CECECECECECECECECECECECECECECECECECECECECECECECECECECECECECECECE
      CECECECECECECEFFFFFFFFFFFFCECECECECECECECECECECECE63636300000031
      3131B5CECEFFFFFFFFFFFFFFFFFFFFFFFF3131319C9C9CCECECECECECECECECE
      CECECECECECE4A4A4A000000000000101818FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFE1FFFF000000E1FFFF9C9C9CCECECECECECECECECECECE
      CE636363000000636363FFFFFFFFFFFFCECECECECECECECECECECECECECECECE
      CECECECECE000000000000CECECECECECE101818000000313131CECECECECECE
      FFFFFFFFFFFFFFFFFF849C9C000000313131CECECECECECECECECECECECECECE
      CEFFFFFFB5CECECECECECECECECECECE636363000000636363CECECECECECECE
      CECE000000000000CECECECECECECECECECECECECECECECECECEB5CECEFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCECECECECECECECECECECECECECE
      CECECECECECECECECECECECECECECECECECECECECECECECECECECECECECECECE
      CECECECECECECECECECECEFFFFFFFFFFFFFFFFFFCECECECECECECECECECECECE
      CECECECECECECECECECECECEB5CECEB5CECECECECECECECECECECECECECECECE
      CECECECECECECEFFFFFFFFFFFFCECECECECECECECECECECECE63636300000031
      3131B5CECEFFFFFFFFFFFFFFFFFFFFFFFF3131319C9C9CCECECECECECECECECE
      CECECE4A4A4A000000000000849C9C313131FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFE1FFFF000000E1FFFF9C9C9CCECECECECECECECECECECE
      CE636363000000636363849C9C849C9C9C9C9CCECECECECECECECECECECECECE
      CECECECECE000000000000CECECE4A4A4A000000000000BDBDBDCECECECECECE
      FFFFFFFFFFFFFFFFFF849C9C000000313131CECECECECECECECECECECECECECE
      CE849C9C849C9C9C9C9C9C9C9C6363630000000000009C9C9CCECECEFFFFFFFF
      FFFF000000000000CECECECECECECECECECECECECECECECECECEB5CECEFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCECECECECECECECECECECECECECE
      CECECECECECECECECECEB5CECEB5CECECECECECECECECECECECECECECECECECE
      CECECECECECECECECECECEB5CECEFFFFFFFFFFFFCECECECECECECECECECECECE
      CECECECECECECECECEFFFFFFFFFFFFFFFFFFCECECECECECECECECECECECECECE
      CECECECECECECEB5CECEFFFFFFCECECECECECECECECECECECE63636300000031
      3131B5CECEFFFFFFFFFFFFFFFFFFFFFFFF3131319C9C9CCECECECECECECECECE
      7B7B7B0000000000007B7B7BFFFFFF313131FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFF000000E1FFFF0000009C9C9CCECECECECECECECECECECE
      CE6363630000006363637373736363634A4A4A0000007B7B7BCECECECECECECE
      CECECECECE000000000000849C9C3131311018184A4A4A9C9C9CCECECECECECE
      FFFFFFFFFFFFFFFFFF849C9C000000313131CECECECECECECECECEBDBDBD3131
      310000000000000000000000000000000000004A4A4ACECECEB5CECEFFFFFFFF
      FFFF000000000000636363636363636363636363636363CECECEB5CECEFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCECECECECECECECECECECECECECE
      CECECECECECECEB5CECEFFFFFFFFFFFFFFFFFFB5CECECECECECECECECECECECE
      CECECECECECECECECECECECECECEFFFFFFB5CECECECECECECECECECECECECECE
      CECECECECECECECECEFFFFFFFFFFFFFFFFFFB5CECECECECECECECECECECECECE
      CECECECECECECEB5CECEFFFFFFCECECECECECECECECECECECE63636300000031
      3131B5CECEFFFFFFFFFFFFFFFFFFFFFFFF3131319C9C9CCECECECECECE7B7B7B
      0000000000007B7B7BB5CECEFFFFFF313131FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFDFDFDAAAAAAAAAAAAFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF4A4A4ACECECE
      FFFFFFFFFFFFFFFFFF849C9C000000313131FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFB5CECEFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCECECECECECE
      CECECECECECECECECEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF9C9C9C000000
      000000636363CECECEB5CECEFFFFFF313131FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000
      000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000FFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000
      000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000FFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000
      000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000000000000000FFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000
      000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000000000000000FFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000
      000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFF000000000000000000000000000000000000FF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF808080808080
      808080808080808080808080808080808080FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFF000000000000000000000000000000000000FF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFF00000000000000000000000000000000000000000000
      0000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF808080808080
      808080808080808080808080808080808080FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFF00000000000000000000000000000000000000000000
      0000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF808080808080
      8080808080808080808080808080808080800000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000300000000100010000000000800100000000000000000000
      000000000000000000000000FFFFFF003123534E414E06310000000000000006
      0000000000000000000000000000000000000000000000000000000003000010
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000200000000000000002020202101010100202020202020202
      02020202020202021010828282828282FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFE03FFFFFF00FFE7FEF9FF00FF00FFE7FEBAFF00F
      F81FFC3FEFB7F00FF81FFC3FEEB7F00FFC3FF81FEFA7F00FFC3FF81FE037F00F
      FE7FF00FF557F00FFE7FF00FFAA7F00FFFFFFFFFFC07FFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000000000
      000000000000}
  end
  object PopupMenu2: TPopupMenu
    AutoPopup = False
    Left = 88
    Top = 240
    object RandomSort: TMenuItem
      Caption = 'Sort randomly'
      OnClick = RandomSortClick
    end
    object ByauthorSort: TMenuItem
      Caption = 'Sort by author'
      OnClick = ByauthorSortClick
    end
    object BytitleSort: TMenuItem
      Caption = 'Sort by title'
      OnClick = BytitleSortClick
    end
    object ByfilenameSort: TMenuItem
      Caption = 'Sort by file name'
      OnClick = ByfilenameSortClick
    end
    object Byfiletype1: TMenuItem
      Caption = 'Sort by file type'
      OnClick = Byfiletype1Click
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object Finditem1: TMenuItem
      Caption = 'Find item...'
      ShortCut = 118
      OnClick = Finditem1Click
    end
  end
end