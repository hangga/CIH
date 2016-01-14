object FormWarna: TFormWarna
  Left = 382
  Top = 44
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'FormWarna'
  ClientHeight = 252
  ClientWidth = 397
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 13
  object bvl1: TBevel
    Left = 10
    Top = 213
    Width = 377
    Height = 6
    Shape = bsTopLine
  end
  object lbl1: TLabel
    Left = 10
    Top = 64
    Width = 88
    Height = 13
    Caption = 'Background/ Latar'
  end
  object lbl2: TLabel
    Left = 10
    Top = 90
    Width = 30
    Height = 13
    Caption = 'Simpul'
  end
  object lbl3: TLabel
    Left = 10
    Top = 142
    Width = 29
    Height = 13
    Caption = 'Rusuk'
  end
  object lbl4: TLabel
    Left = 10
    Top = 168
    Width = 81
    Height = 13
    Caption = 'Rusuk terpendek'
  end
  object lbl5: TLabel
    Left = 10
    Top = 116
    Width = 60
    Height = 13
    Caption = 'Nama Simpul'
  end
  object bvl2: TBevel
    Left = 10
    Top = 44
    Width = 377
    Height = 7
    Shape = bsTopLine
  end
  object Label1: TLabel
    Left = 266
    Top = 142
    Width = 52
    Height = 13
    Caption = 'Tebal garis'
  end
  object Label2: TLabel
    Left = 266
    Top = 168
    Width = 52
    Height = 13
    Caption = 'Tebal garis'
  end
  object lbl6: TLabel
    Left = 365
    Top = 142
    Width = 16
    Height = 13
    Caption = 'mm'
  end
  object lbl7: TLabel
    Left = 365
    Top = 166
    Width = 16
    Height = 13
    Caption = 'mm'
  end
  object btnOke: TBitBtn
    Left = 232
    Top = 221
    Width = 75
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 9
  end
  object btnBatal: TBitBtn
    Left = 312
    Top = 221
    Width = 75
    Height = 25
    Caption = 'Batal'
    ModalResult = 2
    TabOrder = 10
  end
  object clrbxLatar: TColorBox
    Left = 128
    Top = 59
    Width = 131
    Height = 22
    Style = [cbStandardColors, cbSystemColors, cbIncludeDefault, cbCustomColor, cbPrettyNames]
    ItemHeight = 16
    TabOrder = 2
    OnCloseUp = clrbxLatarCloseUp
  end
  object clrbxRusuk: TColorBox
    Left = 128
    Top = 137
    Width = 131
    Height = 22
    Style = [cbStandardColors, cbSystemColors, cbIncludeDefault, cbCustomColor, cbPrettyNames]
    ItemHeight = 16
    TabOrder = 5
    OnCloseUp = clrbxLatarCloseUp
  end
  object clrbxRusukPendek: TColorBox
    Left = 128
    Top = 163
    Width = 131
    Height = 22
    Style = [cbStandardColors, cbSystemColors, cbIncludeDefault, cbCustomColor, cbPrettyNames]
    ItemHeight = 16
    TabOrder = 7
    OnCloseUp = clrbxLatarCloseUp
  end
  object clrbxsIMPUL: TColorBox
    Left = 128
    Top = 85
    Width = 131
    Height = 22
    Style = [cbStandardColors, cbSystemColors, cbIncludeDefault, cbCustomColor, cbPrettyNames]
    ItemHeight = 16
    TabOrder = 3
    OnCloseUp = clrbxLatarCloseUp
  end
  object clrbxNamaSimpul: TColorBox
    Left = 128
    Top = 111
    Width = 131
    Height = 22
    Style = [cbStandardColors, cbSystemColors, cbIncludeDefault, cbCustomColor, cbPrettyNames]
    ItemHeight = 16
    TabOrder = 4
    OnCloseUp = clrbxLatarCloseUp
  end
  object rbdEFAULT: TRadioButton
    Left = 10
    Top = 17
    Width = 65
    Height = 17
    Caption = 'Default'
    TabOrder = 0
    OnClick = rbdEFAULTClick
  end
  object rbcUSTOM: TRadioButton
    Left = 96
    Top = 17
    Width = 89
    Height = 17
    Caption = 'Custom'
    TabOrder = 1
    OnClick = rbdEFAULTClick
  end
  object serUSUK: TSpinEdit
    Left = 320
    Top = 137
    Width = 41
    Height = 22
    MaxLength = 1
    MaxValue = 5
    MinValue = 1
    TabOrder = 6
    Value = 1
    OnChange = serUSUKChange
  end
  object sehASIL: TSpinEdit
    Left = 320
    Top = 163
    Width = 41
    Height = 22
    MaxLength = 1
    MaxValue = 5
    MinValue = 1
    TabOrder = 8
    Value = 1
    OnChange = serUSUKChange
  end
end
