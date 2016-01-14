unit uAbout;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, ShellAPI;

type
  TAboutBox = class(TForm)
    Panel1: TPanel;
    ProgramIcon: TImage;
    ProductName: TLabel;
    Version: TLabel;
    Copyright: TLabel;
    OKButton: TButton;
    lbl1: TLabel;
    lblLink: TLabel;
    procedure lblLinkClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutBox: TAboutBox;

  procedure ShowAbout;

implementation

{$R *.dfm}

procedure ShowAbout;
begin
   with TAboutBox.Create(Application) do
   try
      if ShowModal = mrOk then
      begin
         Close;
      end;  
   finally
      Free;
   end;
end;  

procedure TAboutBox.lblLinkClick(Sender: TObject);
begin
   ShellExecute(
    Application.Handle,
    'open',
    'http://www.inspirasiku.tk',
    nil,
    nil,
    0);
end;

end.
 
