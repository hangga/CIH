unit uWarna;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Spin;

type
  TFormWarna = class(TForm)
    btnOke: TBitBtn;
    btnBatal: TBitBtn;
    clrbxLatar: TColorBox;
    clrbxRusuk: TColorBox;
    clrbxRusukPendek: TColorBox;
    clrbxsIMPUL: TColorBox;
    clrbxNamaSimpul: TColorBox;
    bvl1: TBevel;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl4: TLabel;
    lbl5: TLabel;
    rbdEFAULT: TRadioButton;
    rbcUSTOM: TRadioButton;
    bvl2: TBevel;
    serUSUK: TSpinEdit;
    sehASIL: TSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    lbl6: TLabel;
    lbl7: TLabel;
    procedure rbdEFAULTClick(Sender: TObject);
    procedure clrbxLatarCloseUp(Sender: TObject);
    procedure serUSUKChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormWarna: TFormWarna;

  function SetWarna : Boolean;
  function GetWarna(Kolom : string): TColor;
  function GetTebal(kolom : string): Integer;

implementation

uses uDm;

{$R *.dfm}

function GetWarna(Kolom : string): TColor;
begin
   with newQuery('select '+kolom+' from WARNA') do
   try
      Open;
      Result := StringToColor(Fields[0].AsString);
   finally
      Free;
   end;
end;

function GetTebal(kolom : string): Integer;
begin
   with newQuery('select '+kolom+' from TEBALGARIS') do
   try
      Open;
      Result := Fields[0].AsInteger;
   finally
      Free;
   end;
end;    

function SetWarna : Boolean;
var
   def : string;
begin
   Result := False;
   with TFormWarna.Create(Application) do
   try
      Caption := 'Warna';
      with newQuery do
      try
         SQL.Text := 'select * from WARNA';
         Open;
         clrbxLatar.Selected := StringToColor(Fieldbyname('LATAR').AsString);
         clrbxsIMPUL.Selected := StringToColor(Fieldbyname('SIM').AsString);
         clrbxNamaSimpul.Selected := StringToColor(Fieldbyname('LABEL').AsString);
         clrbxRusuk.Selected := StringToColor(Fieldbyname('RUSUK').AsString);
         clrbxRusukPendek.Selected := StringToColor(Fieldbyname('PENDEK').AsString);

         if FieldByName('DEF').AsString = '1' then rbdEFAULT.Checked := True else
         rbcUSTOM.Checked := True;

         SQL.Text := 'select RUSUK,RUSUKHASIL from TEBALGARIS';
         Open;
         serUSUK.Value := Fields[0].AsInteger;
         sehASIL.Value := Fields[1].AsInteger;

         if ShowModal = mrOk then
         begin
            SQL.Text := 'update WARNA set SIM=:SIM,RUSUK=:RUSUK,PENDEK=:PENDEK,'+
            'LABEL=:LABEL,LATAR=:LATAR,DEF=:def';
            ParamByName('SIM').AsString := ColorToString(clrbxsIMPUL.Selected);
            ParamByName('RUSUK').AsString := ColorToString(clrbxRusuk.Selected);
            ParamByName('PENDEK').AsString := ColorToString(clrbxRusukPendek.Selected);
            ParamByName('LABEL').AsString := ColorToString(clrbxNamaSimpul.Selected);
            ParamByName('LATAR').AsString := ColorToString(clrbxLatar.Selected);
            if rbdEFAULT.Checked = True then def := '1' else def := '0';
            ParamByName('def').AsString := def;
            ExecSQL;
            Commit;

            SQL.Text := 'update TEBALGARIS set RUSUK=:RUSUK,RUSUKHASIL=:RUSUKHASIL';
            ParamByName('RUSUK').AsInteger := serUSUK.Value;
            ParamByName('RUSUKHASIL').AsInteger := sehASIL.Value;
            ExecSQL;
            Commit;
            Result := True;
         end;
      finally
         Free;
      end;
   finally
      Free;
   end;
end;  

procedure TFormWarna.rbdEFAULTClick(Sender: TObject);
begin
   if rbdEFAULT.Checked = True then
   begin
      clrbxLatar.Selected := $00FFE6DF;
      clrbxsIMPUL.Selected := $00A48377;
      clrbxNamaSimpul.Selected := clNavy;
      clrbxRusuk.Selected := $00FFB0B0;
      clrbxRusukPendek.Selected := clRed;
      serUSUK.Value := 1;
      sehASIL.Value := 2;
   end;    
end;

procedure TFormWarna.clrbxLatarCloseUp(Sender: TObject);
begin
   rbcUSTOM.Checked := True;
end;

procedure TFormWarna.serUSUKChange(Sender: TObject);
begin
   rbcUSTOM.Checked := True;
end;

end.
