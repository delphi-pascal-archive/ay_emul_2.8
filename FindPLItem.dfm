object Form9: TForm9
  Left = 359
  Top = 199
  BorderStyle = bsDialog
  Caption = 'Find playlist item'
  ClientHeight = 166
  ClientWidth = 218
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 121
    Height = 57
    Caption = 'Search string'
    TabOrder = 0
    object Edit1: TEdit
      Left = 8
      Top = 24
      Width = 105
      Height = 21
      TabOrder = 0
    end
  end
  object RadioGroup1: TRadioGroup
    Left = 8
    Top = 72
    Width = 121
    Height = 89
    Caption = 'Search area'
    ItemIndex = 0
    Items.Strings = (
      'Anywhere'
      'Author name'
      'Music title'
      'File name')
    TabOrder = 1
  end
  object Button1: TButton
    Left = 136
    Top = 16
    Width = 75
    Height = 25
    Caption = 'Find next'
    Default = True
    TabOrder = 2
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 136
    Top = 48
    Width = 75
    Height = 25
    Caption = 'Find all'
    ModalResult = 1
    TabOrder = 3
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 136
    Top = 80
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Close'
    ModalResult = 2
    TabOrder = 4
  end
end
