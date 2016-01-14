{----------------------------------------------------------------------------- 
	MODULE:		fb_embedded.pas
	DESCRIPTION:	Embed Firebird into EXE

 Software is distributed on an "AS IS" basis,
 WITHOUT WARRANTY OF ANY KIND, either express
 or implied.

 The Original Code was created by Fikret Hasovic - http://fikret.fbtalk.net
                                  fikret.hasovic@gmail.com

 Contributor(s): Si Carter - http://www.tectsoft.com.

 History:
 2005/05/12 - 0.9a: The first release. Removed some unfinished code and published.
 2005/05/15 - 1.00: The first complete release. Si Carter contributed code.
                    Now it deletes firebird embedded files on close 
 All Rights Reserved.

 You may use or modify this code as long as the above
 copyright and author information is not changed or removed.
-----------------------------------------------------------------------------}

unit fb_embedded;
{$R FB1.5_Embedded.RES}  //<-- DON'T FORGET
interface
uses
  SysUtils, Classes, Forms, Windows;

const
  dll_gds32 = 'gds32.dll';
  dll_fbembed = 'fbembed.dll';
  msg_firebird = 'firebird.msg';
  conf_firebird = 'firebird.conf';
  conf_aliases = 'aliases.conf';
  dll_ibutil = 'ib_util.dll';
  dll_fbudf = 'fbudf.dll';
  dll_ib_udf = 'ib_udf.dll';
  dll_fbintl = 'fbintl.dll';

  Rdll_gds32 = 'dll_fbembed';
  Rdll_fbembed = 'dll_fbembed';
  Rmsg_firebird = 'msg_firebird';
  Rconf_firebird = 'conf_firebird';
  Rconf_aliases = 'conf_aliases';
  Rdll_ibutil = 'dll_ibutil';
  Rdll_fbudf = 'dll_fbudf';
  Rdll_ib_udf = 'dll_ib_udf';
  Rdll_fbintl = 'dll_fbintl';

function Install: Integer;
function Remove: Integer;

implementation

uses FileCtrl;

function Install: Integer;

  procedure ExtractFile(const ResName, FileName: string);
  var
    rStream: TResourceStream;
    fStream: TFileStream;
  begin
    rStream := TResourceStream.Create(hInstance, ResName,
      RT_RCDATA);
    try
      fStream := TFileStream.Create(FileName, fmCreate);
      try
        fStream.CopyFrom(rStream, 0);
      finally
        fStream.Free;
      end;
    finally
      rStream.Free;
    end;
  end;

  procedure CreateFolder(const Folder: string);
  begin
    if not DirectoryExists(Folder) then
      if not CreateDir(Folder) then
        raise Exception.CreateFmt('Cannot create folder: %s', [Folder]);
  end;

var
  RootPath: string;
begin
  Result := 1;
  try
    RootPath := IncludeTrailingBackslash(ExtractFilePath(Application.ExeName));

    CreateFolder(RootPath + 'udf');
    CreateFolder(RootPath + 'intl');

    ExtractFile(Rdll_gds32, RootPath + dll_gds32);
    ExtractFile(Rdll_fbembed, RootPath + dll_fbembed);
    ExtractFile(Rmsg_firebird, RootPath + msg_firebird);
    ExtractFile(Rconf_firebird, RootPath + conf_firebird);
    ExtractFile(Rconf_aliases, RootPath + conf_aliases);
    ExtractFile(Rdll_ibutil, RootPath + dll_ibutil);
    ExtractFile(Rdll_fbudf, RootPath + 'udf\' + dll_fbudf);
    ExtractFile(Rdll_ib_udf, RootPath + 'udf\' + dll_ib_udf);
    ExtractFile(Rdll_fbintl, RootPath + 'intl\' + dll_fbintl);
  except
    Result := 0;
  end
end;

function Remove: Integer;

  procedure DelFile(const FileName: string);
  begin
    // unload file (if its loaded) so we can remove all traces
    if (GetModuleHandle(PChar(FileName)) <> 0) then
      FreeLibrary(GetModuleHandle(PChar(FileName)));
      
    DeleteFile(PChar(FileName));
  end;

var
  RootPath: string;
begin
  Result := 1;
  try
    RootPath := IncludeTrailingBackslash(ExtractFilePath(Application.ExeName));

    DelFile(RootPath + 'intl\' + dll_fbintl);
    DelFile(RootPath + 'udf\' + dll_fbudf);
    DelFile(RootPath + 'udf\' + dll_ib_udf);
    DelFile(RootPath + dll_ibutil);
    DelFile(RootPath + conf_aliases);
    DelFile(RootPath + conf_firebird);
    DelFile(RootPath + msg_firebird);
    DelFile(RootPath + dll_fbembed);
    DelFile(RootPath + dll_gds32);

    RemoveDir(RootPath + 'intl');
    RemoveDir(RootPath + 'udf');
  except
    Result := 0;
  end
end;

initialization
  if Install = 0 then
    raise Exception.Create('Error initializing Firebird embedded');

finalization
  if Remove = 0 then
    raise Exception.Create('Error un-initializing Firebird embedded');
end.

