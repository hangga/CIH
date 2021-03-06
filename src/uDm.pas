unit uDm;

interface

uses
  SysUtils, Classes, DB, IBDatabase, IBCustomDataSet, IBQuery, Windows, Forms,
  Dialogs;

type
  TDM = class(TDataModule)
    ibtrnsctn1: TIBTransaction;
    ibdtbs1: TIBDatabase;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure InputDate;
    function GetDateP : TDateTime;
    function DateBlank : Boolean;
  end;

var
  DM: TDM;

  function GetComputerNetName: string;
  function newQuery(cmd : string='') : TIBQuery;
  function gen_id(nama : string) : Integer;
  procedure ResetGen(gen_name : string);
  procedure Commit;
  procedure Rollback;

implementation

{$R *.dfm}

function newQuery(cmd : string='') : TIBQuery;
begin
    Result:=TIBQuery.Create(DM);
    Result.Database:=DM.ibdtbs1;
    Result.Transaction:=DM.ibtrnsctn1;
    Result.SQL.Text:=cmd;
end;

function GetComputerNetName: string;
var
 buffer: array[0..255] of char;
 size: dword;
begin
 size := 256;
 if GetComputerName(buffer, size) then
   Result := buffer
 else
   Result := ''
end;

procedure Commit;
begin
    DM.ibtrnsctn1.Commit;
    DM.ibtrnsctn1.StartTransaction;
end;

procedure Rollback;
begin
    DM.ibtrnsctn1.Rollback;
    DM.ibtrnsctn1.StartTransaction;
end;

function gen_id(nama : string) : Integer;
var
  hasil : Integer;
begin
  with newQuery do
  try
      SQL.Text := 'select gen_id('+trim(nama)+',1) from rdb$database';
      Open;
      hasil := Fields[0].AsInteger;
  finally
      Free;
  end;
  Result := hasil;
end;

procedure ResetGen(gen_name : string);
begin
  with newQuery('SET GENERATOR '+gen_name+' TO 0') do
  try
    ExecSQL;
    commit;
  finally
    Free
  end;
end;

{ TDM }

function TDM.DateBlank: Boolean;
begin
   Result := True;
   with newQuery('select count(*) from seting') do
   try
      Open;
      if Fields[0].AsInteger > 0 then Result := False;
   finally
      Free;
   end;
end;

function TDM.GetDateP: TDateTime;
begin
   with newQuery('select tgl from seting') do
   try
      Open;
      Result := Fields[0].AsDateTime;
   finally
      Free;
   end;
end;

procedure TDM.InputDate;
begin
   with newQuery do
   try
      SQL.Text := 'insert into seting(tgl) values(:t)';
      ParamByName('t').AsDateTime := Now;
      ExecSQL;
      Commit;
   finally
      Free;
   end;
end;

end.
