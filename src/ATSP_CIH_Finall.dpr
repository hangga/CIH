program ATSP_CIH_Finall;

uses
  Forms,
  uUtama in 'uUtama.pas' {FormUtama},
  uDm in 'uDm.pas' {DM: TDataModule},
  uWarna in 'uWarna.pas' {FormWarna},
  uAbout in 'uAbout.pas' {AboutBox},
  fb_embedded in 'fb_embedded.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Asymmetric Traveling Salesman Problem With CIH Algorithm';
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TFormUtama, FormUtama);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.Run;
end.
