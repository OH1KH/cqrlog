unit fAbout;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, lclintf, ComCtrls, Grids;

type

  { TfrmAbout }

  TfrmAbout = class(TForm)
    Bevel1 : TBevel;
    Bevel2: TBevel;
    btnChangelog : TButton;
    btnChangelog1: TButton;
    btnClose : TButton;
    btnClose1: TButton;
    Image1 : TImage;
    Image2: TImage;
    Label1 : TLabel;
    Label10: TLabel;
    Label2 : TLabel;
    Label3 : TLabel;
    Label4: TLabel;
    Label5 : TLabel;
    Label6: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lblLink : TLabel;
    lblLink1: TLabel;
    lblLink2: TLabel;
    lblLink3: TLabel;
    lblVerze : TLabel;
    lblVerze1: TLabel;
    PageControl1 : TPageControl;
    sgContributors: TStringGrid;
    tabAbout : TTabSheet;
    tabContributors : TTabSheet;
    tabUpgrade: TTabSheet;
    procedure btnChangelogClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lblLinkClick(Sender: TObject);
    procedure lblLinkMouseEnter(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  frmAbout: TfrmAbout;

implementation

{$R *.lfm}

{ TfrmAbout }
uses fChangelog, uVersion;

procedure TfrmAbout.lblLinkMouseEnter(Sender: TObject);
begin
  (Sender as TLabel).Cursor:= crHandPoint
end;

procedure TfrmAbout.lblLinkClick(Sender: TObject);
begin
  openURl((Sender as TLabel).Caption);
end;

procedure TfrmAbout.btnChangelogClick(Sender: TObject);
begin
  with TfrmChangelog.Create(Application) do
  try
    ShowModal
  finally
    Free
  end
end;

procedure TfrmAbout.FormShow(Sender: TObject);
begin
  lblVerze.Caption := cVERSION + '  ' + cBUILD_DATE
end;

end.

