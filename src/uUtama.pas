unit uUtama;

//{$00F48C00}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ImgList, ComCtrls, ToolWin, ExtCtrls, StdCtrls, Grids,
  NiceGrid, DB, IBCustomDataSet, IBQuery, ActnList, Spin, ExtDlgs;

type
  TFormUtama = class(TForm)
    mmMenuUtama: TMainMenu;
    File1: TMenuItem;
    NewProject1: TMenuItem;
    Exit1: TMenuItem;
    il1: TImageList;
    Help1: TMenuItem;
    pm1: TPopupMenu;
    mniSimpulBaru1: TMenuItem;
    N1: TMenuItem;
    Run1: TMenuItem;
    Proses1: TMenuItem;
    actlst1: TActionList;
    actProses: TAction;
    actNew: TAction;
    Bantuan1: TMenuItem;
    N3: TMenuItem;
    actHelp: TAction;
    stat1: TStatusBar;
    actDelDate: TAction;
    About1: TMenuItem;
    pnlTabel: TPanel;
    pnlSubA: TPanel;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl4: TLabel;
    bvl1: TBevel;
    rbManu: TRadioButton;
    cbbA: TComboBox;
    cbbB: TComboBox;
    rbAcak: TRadioButton;
    seAcak: TSpinEdit;
    GrdJarak: TNiceGrid;
    img1: TImage;
    rbOto: TRadioButton;
    mmoProses: TMemo;
    SimpanGraf1: TMenuItem;
    dlgPic: TSavePictureDialog;
    SimpanGambar1: TMenuItem;
    N4: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Exit1Click(Sender: TObject);
    procedure FormDblClick(Sender: TObject);
    procedure NewProject1Click(Sender: TObject);
    procedure FormContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure Proses1Click(Sender: TObject);
    procedure rbManuClick(Sender: TObject);
    procedure Bantuan1Click(Sender: TObject);
    procedure actDelDateExecute(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure SimpanGraf1Click(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    procedure DrawGradient(ACanvas: TCanvas; Rect: TRect;
        Horicontal: Boolean; Colors: array of TColor);
    procedure new_shape(x,y : Integer); {membuat shape berbentuk lingkaran}
    procedure new_label_shape(x,y : Integer); {memberi nama simpul sesuai index}
    procedure BuatSimpul;
    procedure ShowJarak;
    function GetJarak(asal, tuj : Integer): Extended; {mendapatkan jarak}
    procedure GetPosisi(no_simpul : Integer; var x, y : Integer);

    procedure GarisHasil(xa,ya,xb,yb : Integer);
    function SubTourMasih : Boolean;
    procedure LabelHasil(param : string);
    procedure SimpanPosisi(noSimpul, x, y : Integer); {menyimpan data koordinat[x,y] posisi simpul}
    procedure SimpanJarak;
    procedure HapusSimpul;
    procedure HapusTabel(nama : string);
    procedure GoProses; {Run/ Proses Komputasi Algoritma CIH}
  end;

type  TSimpul = record
      tX    : array[Byte] of Integer;
      tY    : array[Byte] of Integer;
      end;

var
  FormUtama: TFormUtama;
  Terproses : Boolean;
  Simpul : TSimpul;
  simpulX, simpulY : TStringList;
  BanyakSimpul : Integer;

  function HitungJarak(XPos, YPos, X, Y: Real): Real;
  function Bulat(Value: Double; n : Integer): Real;
  Procedure SimpanGambar(Img : TImage; MyBitmap: TBitMap);{Buat nyimpan gambar}


implementation

uses uDm, Math, uWarna, uAbout, dateutils;

{$R *.dfm}

Procedure SimpanGambar(Img : TImage; MyBitmap: TBitMap);
var
  c: TCanvas;
  r, t: TRect;
begin
  c:= TCanvas.Create;
  c.Handle:= GetWindowDC (GetDesktopWindow);
  try
    r:= Rect(0,45,img.width,img.height);
    t:= Rect(0,0,img.width,img.height - 45);
    MyBitmap.Width:= img.width;
    MyBitmap.Height:= img.Height - 45;
    MyBitmap.Canvas.CopyRect(t, c, r);
  finally
    ReleaseDC(0, c.handle);
    c.Free;
  end;
end;


function HitungJarak(XPos, YPos, X, Y: Real): Real;
begin
    Result:=sqrt(Power(XPos-X,2)+Power(YPos-Y,2));
end;

function Bulat(Value: Double; n : Integer): Real;
var
    j: Integer;
    A: Real;
begin
    A:=1;
    Case n of
      0 : A:=1;
      1 : A:=10;
    else
    for j:=1 to n do
      A := A * 10;
    end;
    Result:=Int((Value * A) + 0.5) / A;
end;

procedure TFormUtama.FormCreate(Sender: TObject);
begin
   WindowState := wsMaximized;
   mniSimpulBaru1.Enabled := True;
   ResetGen('G_NOMOR');
   ResetGen('G_PROSES');
   HapusTabel('HASIL');
   HapusTabel('SIMPUL');
   HapusTabel('JARAK');
   HapusTabel('PROSES');
   Caption := Application.Title;
   simpulX := TStringList.Create;
   simpulY := TStringList.Create;
   Terproses := False;
   img1.Width := FormUtama.Width - pnlTabel.Width;
   FormUtama.Color := clWhite;
end;

procedure TFormUtama.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
   if MessageDlg('Anda Mau Keluar ?',mtConfirmation,[mbYes,mbNo],0) = mrYes then
   begin
      HapusSimpul;
      ResetGen('G_NOMOR');
      ResetGen('G_PROSES');
      HapusTabel('HASIL');
      HapusTabel('JARAK');
      HapusTabel('SIMPUL');
      HapusTabel('PROSES');
      Application.Terminate;
   end else CanClose := False;
end;

procedure TFormUtama.Exit1Click(Sender: TObject);
begin
   Close;
end;

procedure TFormUtama.new_shape(x, y: Integer);
var
    titik : TShape;
    i, j : Integer;
begin
    j := 0;                       {
    img1.Canvas.Pen.Color := GetWarna('SIM');
    img1.Canvas.Pen.Width := 15;
    img1.Canvas.MoveTo(x+7,y+7);
    img1.Canvas.LineTo(x+7,y+7); }

    titik := TShape.Create(FormUtama);
    titik.Parent := FormUtama;
    titik.Shape := stCircle;
    titik.Pen.Color := GetWarna('SIM');
    titik.Pen.Mode := pmCopy;
    titik.Brush.Color := GetWarna('SIM');
    titik.Width := 14;
    titik.Height := 14;
    titik.Visible := True;
    titik.Left := x;
    titik.Top :=  y;
    titik.Cursor := crHandPoint;
    titik.ShowHint := True;

    for i := 0 to ComponentCount -1 do
    begin
        if Components[i] is TShape then
        begin
            j := j + 1;
            BanyakSimpul := j;
            TShape(Components[i]).Refresh;
        end;
    end;   
    cbbB.Items.Add(IntToStr(j));
    cbbA.Items.Add(IntToStr(j));
end;

procedure TFormUtama.new_label_shape(x, y: Integer);
var
    lbl : TLabel;
    i, j : Integer;
begin
    j := 0;
    for i := 0 to ComponentCount - 1 do
    begin
        if Components[i] is TShape then j := j + 1;
    end;

    lbl := TLabel.Create(FormUtama);
    lbl.Transparent := True;
    lbl.Parent := FormUtama;
    lbl.Left := x;
    lbl.Top := y;
    lbl.Caption := inttostr(j);
    lbl.Transparent := True;
    lbl.Font.Color := GetWarna('LABEL');
    lbl.Font.Style := [fsBold];
    lbl.AutoSize := True;
    lbl.Font.Size := 10;
    lbl.Visible := True;
end;

procedure TFormUtama.BuatSimpul;
var
    t : TPoint;
    i, x, y : Integer;
begin
    GetCursorPos(t); {mendapatkan koordinat posisi kursor}
    x := t.X - 10;
    y := t.Y - 50; {50}

    new_shape(x,y);

    simpulX.Add(IntToStr(x));
    simpulY.Add(IntToStr(y));
    Img1.Canvas.Pen.Color := GetWarna('RUSUK');
    Img1.Canvas.Pen.Width := GetTebal('RUSUK');
    Img1.Canvas.MoveTo(x+7,y+7);
    SimpanPosisi(BanyakSimpul,x+7,y+7);
    for i := 0 to simpulX.Count - 1 do
    begin
        Img1.Canvas.MoveTo(StrToInt(simpulX[i])+7, StrToInt(simpulY[i])+7);
        Img1.Canvas.LineTo(x+7,y+7);
    end;
    new_label_shape(t.X, t.Y - 70); {label nama shape}
    ShowJarak;
    img1.Transparent := True;
    
    if Trim(cbbA.Text) = '' then cbbA.ItemIndex := 0;
    if Trim(cbbB.Text) = '' then cbbB.ItemIndex := 1;
end;


procedure TFormUtama.FormDblClick(Sender: TObject);
begin
   if Terproses = False then
   BuatSimpul;
end;

procedure TFormUtama.NewProject1Click(Sender: TObject);
begin
   HapusSimpul;
   FormUtama.Free;
   Application.CreateForm(TFormUtama, FormUtama);
   FormUtama.Show;
end;

procedure TFormUtama.FormContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
    i, j : Integer;
begin
    j := 0;
    for i := 0 to ComponentCount - 1 do
    begin
        if Components[i] is TShape then
        begin
            j := j + 1;
        end;  
    end;
    mniSimpulBaru1.Caption := 'Simpul ('+inttostr(j+1)+')';
end;

procedure TFormUtama.rbManuClick(Sender: TObject);
var
   i : Integer;
begin
   if rbManu.Checked = True then
   begin
      GrdJarak.Columns[3].ReadOnly := False;
      for i := 0 to GrdJarak.RowCount -1 do
      GrdJarak.Cells[3, i] := '';
   end else ShowJarak;
end;

procedure TFormUtama.ShowJarak;
var
   i, j, jarak_acak : Integer;
   jarak : Double;
begin
   GrdJarak.RowCount := 0;
   GrdJarak.Columns[3].ReadOnly := True;
   for i := 0 to simpulX.Count - 1 do
   begin
      for j := 0 to simpulX.Count - 1 do
      begin
         if j <> i then
         begin
            GrdJarak.AddRow;
            jarak := HitungJarak(StrToInt(simpulX[j]), StrToInt(simpulY[j]),
                                       StrToInt(simpulX[i]), StrToInt(simpulY[i]));
            jarak := Bulat(jarak,4);
            GrdJarak.Cells[0, GrdJarak.RowCount - 1] := IntToStr(i+1);
            GrdJarak.Cells[1, GrdJarak.RowCount - 1] := IntToStr(j+1);
            GrdJarak.Cells[2, GrdJarak.RowCount - 1] := 'd('+IntToStr(i+1)+','+IntToStr(j+1)+')';

            if rbOto.Checked = True then
            GrdJarak.Cells[3, GrdJarak.RowCount - 1] := FloatToStr(jarak);

            if rbManu.Checked = True then
            begin
               GrdJarak.Cells[3, GrdJarak.RowCount - 1] := '';
               GrdJarak.Columns[3].ReadOnly := False;
            end;

            if rbAcak.Checked = True then
            begin
               Randomize;
               jarak_acak := RandomRange(1,seAcak.Value);
               GrdJarak.Cells[3, GrdJarak.RowCount - 1] := IntToStr(jarak_acak);
            end;
         end;
      end;
   end;
end;

procedure TFormUtama.SimpanPosisi(noSimpul, x, y: Integer);
begin
   with newQuery do
   try
      SQL.Text := 'insert into SIMPUL(NAMASIMPUL,POSX,POSY) '+
      ' values(:NAMA,:POSX,:POSY)';
      ParamByName('NAMA').AsInteger := noSimpul;
      ParamByName('POSX').AsInteger := x;
      ParamByName('POSY').AsInteger := y;
      ExecSQL;
      Commit;
   finally
      Free;
   end;
end;

procedure TFormUtama.HapusSimpul;
begin
   with newQuery('delete from SIMPUL') do
   try
      ExecSQL;
      Commit;
   finally
      Free;
   end;
end;

procedure TFormUtama.SimpanJarak;
var
   i : Integer;
   jarak : Extended;
begin
   with newQuery do
   try
      for i := 0 to GrdJarak.RowCount - 1 do
      begin
         if Length(Trim(GrdJarak.Cells[3,i])) > 0 then
            jarak := StrToFloat(Trim(GrdJarak.Cells[3,i])) else jarak := 0;
         
         SQL.Text := 'insert into JARAK(ASAL,TUJUAN,JARAK) '+
         ' values(:ASAL,:TUJUAN,:JARAK)';
         ParamByName('ASAL').AsInteger := StrToInt(GrdJarak.Cells[0,i]);
         ParamByName('TUJUAN').AsInteger := StrToInt(GrdJarak.Cells[1,i]);
         ParamByName('JARAK').AsFloat := jarak;
         ExecSQL;
         Commit;
      end;
   finally
      Free;
   end;
end;

function TFormUtama.GetJarak(asal, tuj: Integer): Extended; {mendapatkan data jarak}
begin
   with newQuery('select JARAK from JARAK where ASAL=:ASAL and TUJUAN=:TUJUAN') do
   try
      ParamByName('TUJUAN').AsInteger := tuj;
      ParamByName('ASAL').AsInteger := asal;
      Open;
      Result := Fields[0].AsFloat;
   finally
      Free;
   end;
end;

procedure TFormUtama.GarisHasil(xa,ya,xb,yb: Integer); {menggambar garis hasil}
begin
   img1.Canvas.Pen.Color := GetWarna('PENDEK');
   img1.Canvas.Pen.Width := GetTebal('RUSUKHASIL');
   img1.Canvas.MoveTo(xa,ya);
   img1.Canvas.LineTo(xb,yb);
end;

procedure TFormUtama.HapusTabel(nama: string);
begin
   with newQuery('delete from  '+nama) do
   try
      ExecSQL;
      Commit;
   finally
      Free;
   end;
end;

procedure TFormUtama.GetPosisi(no_simpul: Integer; var x, y: Integer);
begin
   with newQuery('select POSX,POSY from SIMPUL where NAMASIMPUL=:n') do
   try
      ParamByName('n').AsInteger := no_simpul;
      Open;
      x := Fields[0].AsInteger;
      y := Fields[1].AsInteger;
   finally
      Free;
   end;
end;

procedure TFormUtama.GoProses; {Run/ Proses Komputasi Algoritma CIH}
var
   nomor,lanjut,
   x, y, x2, y2, i,
   j, k, l, m, o, p,
   q, asal_kecil,
   sisip_kecil,
   tuj_kecil,
   asal_h, tuj_h,
   BANYAK_PROSES, tLanjut,
   asal, tuj     : Integer;

   asal_jarak,
   asal_hasil,
   tuj_hasil         : array[0..100] of Integer;

   jarak, TotaJarak  : Extended;
   
   A_H, T_H          : array[0..100] of Integer;
   strh, pilih       : string;
   t1, t2       : tdatetime;
   thasil : int64;
begin
   Terproses := True;
   Proses1.Enabled := False;
   actProses.Enabled := False;
   mniSimpulBaru1.Enabled := False;
   rbOto.Enabled := False;
   rbManu.Enabled := False;
   rbAcak.Enabled := False;
   GrdJarak.Columns[2].ReadOnly := True;
   cbbA.Enabled := False;
   cbbB.Enabled := False;
   seAcak.Enabled := False;
   SimpanGraf1.Enabled := True;
   SimpanGambar1.Enabled := True;

   HapusTabel('HASIL');
   HapusTabel('PROSES');
   ResetGen('G_NOMOR');
   ResetGen('G_PROSES');
   SimpanJarak;
   nomor := 2;
   with newQuery do
   try
      {pilih perjalanan Awal}
      SQL.Text := 'insert into HASIL(NOMOR,ASAL,TUJUAN) values(:n,:a,:t)';
      ParamByName('n').AsInteger := 1; {nomor}
      ParamByName('a').AsInteger := StrToInt(Trim(cbbA.Text));
      ParamByName('t').AsInteger := StrToInt(Trim(cbbB.Text));
      ExecSQL;
      Commit;

      SQL.Text := 'insert into HASIL(NOMOR,ASAL,TUJUAN) values(:n,:a,:t)';
      ParamByName('n').AsInteger := 2; {nomor}
      ParamByName('a').AsInteger := StrToInt(Trim(cbbB.Text));
      ParamByName('t').AsInteger := StrToInt(Trim(cbbA.Text));
      ExecSQL;
      Commit;
      
      while SubTourMasih = True do
      begin
         {mencari asal dari tabel jarak yang belum masuk dalam subtour}
         i := 0;
         SQL.Text := ' select distinct asal from jarak '+
         ' where asal not in (select asal from hasil) ';
         Open;
         while not Eof do
         begin
            i := i + 1;
            asal_jarak[i] := Fields[0].AsInteger;
            Next;
         end;
         strh := '';
         mmoProses.Lines.Add('');

         {menyimpan asal, tujuan dari tabel hasil ke dalam variabel}
         j := 0;
         SQL.Text := 'select asal, tujuan from hasil order by asal';
         Open;
         while not Eof do
         begin
            j := j + 1;
            asal_hasil[j] := Fields[0].AsInteger;
            tuj_hasil[j] := Fields[1].AsInteger;
            Next;
         end;

         SQL.Text := 'select count(*) from hasil';
         Open;

         tLanjut := 0;
         lanjut := StrToInt(Trim(cbbA.Text));
         while tLanjut <> StrToInt(Trim(cbbA.Text)) do
         begin
            SQL.Text := 'select asal, tujuan from hasil where asal=:a';
            ParamByName('a').AsInteger := lanjut;
            Open;
            lanjut := Fields[1].AsInteger;
            tLanjut := Fields[1].AsInteger;
            while not Eof do
            begin
               if Fields[1].AsInteger = lanjut then
               begin
                  strh := strh +' --> '+inttostr(fields[0].asinteger);
               end;
               Next;
            end;  
         end;  


         strh := Copy(strh,5,Length(strh));
         mmoProses.Lines.Add(' SUBTOUR  :  '+strh+' --> '+inttostr(fields[1].asinteger));
         mmoProses.Lines.Add('');
         mmoProses.Lines.Add(' Arc      |   Tambahan_jarak');
         mmoProses.Lines.Add(' -----------------------------------------------------------');

         {jika masih ada subtour yang belum masuk maka lakukan}
         if SubTourMasih = True then
         begin
            for k := 1  to i do
            begin
               for l := 1 to j do
               begin
                  {memasukan data ke tabel proses}
                  SQL.Text := 'insert into PROSES(ASAL,TUJUAN,SISIP,ID_PROSES)'+
                  ' values(:ASAL,:TUJUAN,:SISIP,:ID_PROSES)';
                  ParamByName('ID_PROSES').AsInteger := gen_id('G_PROSES');
                  ParamByName('ASAL').AsInteger := asal_hasil[l];
                  ParamByName('TUJUAN').AsInteger := tuj_hasil[l];
                  ParamByName('SISIP').AsInteger := asal_jarak[k];
                  ExecSQL;
                  Commit;
               end;
            end;

            {cari tambahan jarak jarak terkecil}
            with newQuery('select * from CHANGE_JARAK') do
            try
               Open;
               asal_kecil := Fields[0].AsInteger;
               sisip_kecil := Fields[1].AsInteger;
               tuj_kecil := Fields[2].AsInteger;

               {hapus tabel hasil yang asal dan tujuan = asal, tujuan jarak}
               SQL.Text := 'delete from hasil where asal=:a and tujuan=:t';
               ParamByName('a').AsInteger := asal_kecil;
               ParamByName('t').AsInteger := tuj_kecil;
               ExecSQL;
               Commit;
            finally
               Free;
            end;

            tLanjut := 0;
            lanjut := StrToInt(Trim(cbbA.Text));

            while tLanjut <> StrToInt(Trim(cbbA.Text)) do
            begin
               SQL.Text := 'select asal, sisip, tujuan, hjarak from proses where asal=:asl';
               ParamByName('asl').AsInteger := lanjut;
               Open;
               lanjut := Fields[2].AsInteger;
               tLanjut := Fields[2].AsInteger;
               while not Eof do
               begin
                  if (Fields[0].AsInteger = asal_kecil) and
                     (Fields[1].AsInteger = sisip_kecil) and
                     (Fields[2].AsInteger = tuj_kecil) then
                        pilih := ' <----  PILIH' else pilih := '';


                  mmoProses.Lines.Add(' ('+IntToStr(Fields[0].AsInteger)+','+inttostr(Fields[2].AsInteger)+
                  ')    |  [ d('+IntToStr(Fields[0].AsInteger)+','+
                  IntToStr(Fields[1].AsInteger)+') + d('+IntToStr(Fields[1].AsInteger)
                  +','+inttostr(Fields[2].AsInteger)+') ]  -  d('+
                  IntToStr(Fields[0].AsInteger)+','+inttostr(Fields[2].AsInteger)+
                  ')  =  '+floattostr(Bulat(Fields[3].Asfloat,4))+pilih);
                  Next;
               end;
            end;

            mmoProses.Lines.Add('');

            {Memasukan asal dan tujuan ke tabel hasil}
            SQL.Text := 'insert into HASIL(NOMOR,ASAL,TUJUAN) values(:n,:a,:t)';
            ParamByName('n').AsInteger := nomor+1;
            ParamByName('a').AsInteger := asal_kecil;
            ParamByName('t').AsInteger := sisip_kecil;
            ExecSQL;
            Commit;

            SQL.Text := 'insert into HASIL(NOMOR,ASAL,TUJUAN) values(:n,:a,:t)';
            ParamByName('n').AsInteger := nomor+1;
            ParamByName('a').AsInteger := sisip_kecil;
            ParamByName('t').AsInteger := tuj_kecil;
            ExecSQL;
            Commit;
            HapusTabel('PROSES');

         end;
      end;

      {Mendapatkan Urutan Simpul-simpul yang terpilih}
      m := 0;
      SQL.Text := 'select asal, tujuan from hasil order by asal';
      Open;
      TotaJarak := 0;
      while not Eof do
      begin
         A_H[m] := Fields[0].AsInteger;
         T_H[m] := Fields[1].AsInteger;
         TotaJarak := TotaJarak + GetJarak(A_H[m],T_H[m]);
         m := m + 1;
         Next;
      end;

      {menggambar rusuk terpendek dengan Canvas.Line}
      for o := 0 to m do
      begin
         GetPosisi(A_H[o],x,y);
         GetPosisi(T_H[o],x2,y2);
         if (x > 0) and (y > 0) and (x2 > 0) and (y2 > 0) then
         GarisHasil(x,y,x2,y2);
         if (x > 0) and (y > 0) and (x2 > 0) and (y2 > 0) then
         GarisHasil(x2,y2,x,y);
      end;
      strh := '';
      tLanjut := 0;
      lanjut := StrToInt(Trim(cbbA.Text));
      while tLanjut <> StrToInt(Trim(cbbA.Text)) do
      begin
         SQL.Text := 'select asal, tujuan from hasil where asal=:a';
         ParamByName('a').AsInteger := lanjut;
         Open;
         lanjut := Fields[1].AsInteger;
         tLanjut := Fields[1].AsInteger;
         while not Eof do
         begin
         if Fields[1].AsInteger = lanjut then
            begin
               strh := strh +' --> '+inttostr(fields[0].asinteger);
            end;
            Next;
         end;
      end;

      strh := Copy(strh,5,Length(strh));
      mmoProses.Lines.Add('');
      mmoProses.Lines.Add(' RUTE TERPENDEK  :  '+strh+' --> '+inttostr(fields[1].asinteger));
      mmoProses.Lines.Add('');
      mmoProses.Lines.Add(' TOTAL JARAK  :  '+floattostr(Bulat(TotaJarak,4)));
      mmoProses.Lines.Add('');
   finally
      Free;
   end;
end;

procedure TFormUtama.Proses1Click(Sender: TObject);
begin
   if (cbbA.ItemIndex > -1) and (cbbB.ItemIndex > -1) then
   begin
      if cbbA.ItemIndex <> cbbB.ItemIndex then
      begin
        mmoProses.Visible := True;
         GoProses;
       //  pgcKanan.ActivePageIndex := 1;
      end else
      MessageDlg('Subtour awal, simpul asal dan tujuan tidak boleh sama !',
      mtWarning,[mbOK],0);
   end else MessageDlg('Pilih Perjalanan ?',mtInformation,[mbOK],0);
end;

function TFormUtama.SubTourMasih: Boolean; {apakah subtour masih ada}
begin
   Result := False;
   with newQuery do
   try
      SQL.Text := 'select count(distinct asal) from jarak '+
      ' where asal not in (select asal from hasil)';
      Open;
      if Fields[0].AsInteger > 0 then Result := True;
   finally
      Free;
   end;
end;

procedure TFormUtama.LabelHasil(param: string);
var
   lbl : TLabel;
begin
   lbl := TLabel.Create(FormUtama);
   lbl.Transparent := True;
   lbl.Parent := Self;
   lbl.Left := 20;
   lbl.Top := 20;
   lbl.Caption := Trim(param);
   lbl.Transparent := True;
   lbl.Font.Color := GetWarna('LABELHASIL');
   lbl.Font.Style := [fsBold];
   lbl.AutoSize := True;
   lbl.Font.Size := 8;
   lbl.Visible := True;
end;

procedure TFormUtama.About1Click(Sender: TObject);
begin
  ShowAbout;
end;

procedure TFormUtama.Bantuan1Click(Sender: TObject);
var
   hlp : TStringList;
begin
   hlp := TStringList.Create;
   hlp.Add('Memulai Project Baru : Tekan Ctrl+N atau menu File -> New');
   hlp.Add('');
   hlp.Add('Membuat Simpul Baru : Double click pada area hitam');
   hlp.Add('');
   hlp.Add('Melihat Hasil : Tekan F12 atau menu Run -> Run');
   MessageDlg(hlp.Text,mtInformation,[mbOk],0);
   hlp.Free;
end;

procedure TFormUtama.actDelDateExecute(Sender: TObject);
begin
   with newQuery('delete from seting') do
   try
      ExecSQL;
      Commit;
   finally
      Free;
   end;
end;

procedure TFormUtama.DrawGradient(ACanvas: TCanvas; Rect: TRect;
  Horicontal: Boolean; Colors: array of TColor);
type
  RGBArray = array[0..2] of Byte;
var
  x, y, z, stelle, mx, bis, faColorsh, mass: Integer;
  Faktor: double;
  A: RGBArray;
  B: array of RGBArray;
  merkw: integer;
  merks: TPenStyle;
  merkp: TColor;
begin
  mx := High(Colors);
  if mx > 0 then
  begin
    if Horicontal then
      mass := Rect.Right - Rect.Left
    else
      mass := Rect.Bottom - Rect.Top;
    SetLength(b, mx + 1);
    for x := 0 to mx do
    begin
      Colors[x] := ColorToRGB(Colors[x]);
      b[x][0] := GetRValue(Colors[x]);
      b[x][1] := GetGValue(Colors[x]);
      b[x][2] := GetBValue(Colors[x]);
    end;
    merkw := ACanvas.Pen.Width;
    merks := ACanvas.Pen.Style;
    merkp := ACanvas.Pen.Color;
    ACanvas.Pen.Width := 1;
    ACanvas.Pen.Style := psSolid;
    faColorsh := Round(mass / mx);
    for y := 0 to mx - 1 do
    begin
      if y = mx - 1 then
        bis := mass - y * faColorsh - 1
      else
        bis := faColorsh;
      for x := 0 to bis do
      begin
        Stelle := x + y * faColorsh;
        faktor := x / bis;
        for z := 0 to 3 do
          a[z] := Trunc(b[y][z] + ((b[y + 1][z] - b[y][z]) * Faktor));
        ACanvas.Pen.Color := RGB(a[0], a[1], a[2]);
        if Horicontal then
        begin
          ACanvas.MoveTo(Rect.Left + Stelle, Rect.Top);
          ACanvas.LineTo(Rect.Left + Stelle, Rect.Bottom);
        end
        else
        begin
          ACanvas.MoveTo(Rect.Left, Rect.Top + Stelle);
          ACanvas.LineTo(Rect.Right, Rect.Top + Stelle);
        end;
      end;
    end;
    b := nil;
    ACanvas.Pen.Width := merkw;
    ACanvas.Pen.Style := merks;
    ACanvas.Pen.Color := merkp;
  end
  else
    // Please specify at least two colors
    raise EMathError.Create('Es müssen mindestens zwei Farben angegeben werden.');
end;

procedure TFormUtama.SimpanGraf1Click(Sender: TObject);
var
  myBitmap : TBitmap;
begin
  if dlgPic.Execute then
    if ModalResult <> mrCancel then
    begin
      myBitmap := TBitmap.Create;
      SimpanGambar(img1,myBitmap);
      myBitmap.SaveToFile(dlgPic.FileName);
      myBitmap.Free;
    end;
end;

end.
