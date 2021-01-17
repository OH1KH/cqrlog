unit fChangeLocator;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons;

type

  { TfrmChangeLocator }

  TfrmChangeLocator = class(TForm)
    btnOK: TButton;
    btnStorno: TButton;
    edtLocator: TEdit;
    lblEnterLocator: TLabel;
    procedure btnOKClick(Sender: TObject);
    procedure edtLocatorChange(Sender: TObject);
    procedure edtLocatorKeyPress(Sender: TObject; var Key: char);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmChangeLocator: TfrmChangeLocator;

implementation
{$R *.lfm}

{ TfrmChangeLocator }
uses dUtils;

procedure TfrmChangeLocator.edtLocatorKeyPress(Sender: TObject; var Key: char);
begin
  if (key = #13) then
  begin
    btnOK.Click;
    Key := #0
  end
end;

procedure TfrmChangeLocator.btnOKClick(Sender: TObject);
begin
   if dmUtils.isLocOK(edtLocator.Text) then
    ModalResult := mrOK
    else
     Begin
        edtLocator.Text:='ERROR!';
        edtLocator.SelStart := Length(edtLocator.Text);
     end;
end;

procedure TfrmChangeLocator.edtLocatorChange(Sender: TObject);
begin
  edtLocator.Text := dmUtils.StdFormatLocator(edtLocator.Text);
  edtLocator.SelStart := Length(edtLocator.Text);
end;

end.

