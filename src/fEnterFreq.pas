(*
 ***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *                                                                         *
 ***************************************************************************
*)


unit fEnterFreq;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Buttons, StdCtrls,LCLType;

type

  { TfrmEnterFreq }

  TfrmEnterFreq = class(TForm)
    btnCancel: TButton;
    btnOK: TButton;
    cmbMode: TComboBox;
    edtFreq: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    procedure edtFreqExit(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure cmbModeChange(Sender: TObject);
    procedure edtFreqKeyPress(Sender: TObject; var Key: char);
  private
    mode : String;
    freq : String;
    { private declarations }
  public
    { public declarations }
  end; 

var
  frmEnterFreq: TfrmEnterFreq;

implementation
{$R *.lfm}

{ TfrmEnterFreq }
uses dUtils, fTRXControl, dData;

procedure TfrmEnterFreq.FormShow(Sender: TObject);

begin
  dmUtils.InsertModes(cmbMode);
  frmTRXControl.GetModeFreqNewQSO(mode,freq);
  cmbMode.Text := mode;
  edtFreq.Clear;
  edtFreq.SetFocus
end;

procedure TfrmEnterFreq.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if (edtFreq.Text<>'') and (key = VK_RETURN) then
    btnOK.Click;
  if key = VK_ESCAPE then
    btnCancel.Click;
end;

procedure TfrmEnterFreq.edtFreqExit(Sender: TObject);
var
   tmp:extended;
begin
  if TryStrToFloat(edtFreq.Text,tmp) then
  begin
   mode := dmUtils.GetModeFromFreq(FloatToStr(tmp/1000));
   cmbMode.Caption:=mode;
  end;
end;

procedure TfrmEnterFreq.btnOKClick(Sender: TObject);
var
  tmp  : Extended;
begin
  if TryStrToFloat(edtFreq.Text,tmp) then
  begin
    mode := cmbMode.Text;
    freq := FloatToStr(tmp);
    frmTRXControl.SetModeFreq(mode,freq);
  end;
  ModalResult := mrOK;
end;

procedure TfrmEnterFreq.cmbModeChange(Sender: TObject);
begin
  cmbMode.Text:=UpperCase(cmbMode.text);
end;

procedure TfrmEnterFreq.edtFreqKeyPress(Sender: TObject; var Key: char);
begin
  if key = #13 then
  begin
    btnOK.Click;
    key := #0;
  end;
end;

end.

