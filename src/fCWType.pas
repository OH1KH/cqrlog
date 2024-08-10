unit fCWType;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Spin, inifiles, lcltype,ActnList, Menus,frCWKeys, Types;

const
  CWTypeMode: Array [0..2] of String=(', Ltr',', Ltr/Word',', Word');

type

  { TfrmCWType }

  TfrmCWType = class(TForm)
    btnClose: TButton;
    btnClear: TButton;
    fraCWKeys1: TfraCWKeys;
    lblToShowMouseOverText: TLabel;
    m: TMemo;
    mnuHead: TMenuItem;
    mnuLtr: TMenuItem;
    mnuWordLtr: TMenuItem;
    mnuWord: TMenuItem;
    pnlMem: TPanel;
    pnlBottom: TPanel;
    popCWmode: TPopupMenu;
    Separator1: TMenuItem;
    procedure btnF10Click(Sender: TObject);
    procedure btnF10MouseEnter(Sender: TObject);
    procedure btnF10MouseLeave(Sender: TObject);
    procedure btnF1Click(Sender: TObject);
    procedure btnF1MouseEnter(Sender: TObject);
    procedure btnF1MouseLeave(Sender: TObject);
    procedure btnF2Click(Sender: TObject);
    procedure btnF2MouseEnter(Sender: TObject);
    procedure btnF2MouseLeave(Sender: TObject);
    procedure btnF3Click(Sender: TObject);
    procedure btnF3MouseEnter(Sender: TObject);
    procedure btnF3MouseLeave(Sender: TObject);
    procedure btnF4Click(Sender: TObject);
    procedure btnF4MouseEnter(Sender: TObject);
    procedure btnF4MouseLeave(Sender: TObject);
    procedure btnF5Click(Sender: TObject);
    procedure btnF5MouseEnter(Sender: TObject);
    procedure btnF5MouseLeave(Sender: TObject);
    procedure btnF6Click(Sender: TObject);
    procedure btnF6MouseEnter(Sender: TObject);
    procedure btnF6MouseLeave(Sender: TObject);
    procedure btnF7Click(Sender: TObject);
    procedure btnF7MouseEnter(Sender: TObject);
    procedure btnF7MouseLeave(Sender: TObject);
    procedure btnF8Click(Sender: TObject);
    procedure btnF8MouseEnter(Sender: TObject);
    procedure btnF8MouseLeave(Sender: TObject);
    procedure btnF9Click(Sender: TObject);
    procedure btnF9MouseEnter(Sender: TObject);
    procedure btnF9MouseLeave(Sender: TObject);
    procedure btnPgDnClick(Sender: TObject);
    procedure btnPgDnMouseEnter(Sender: TObject);
    procedure btnPgDnMouseLeave(Sender: TObject);
    procedure btnPgUpClick(Sender: TObject);
    procedure btnPgUpMouseEnter(Sender: TObject);
    procedure btnPgUpMouseLeave(Sender: TObject);
    procedure edtSpeedMouseLeave(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure fraCWKeys1Resize(Sender: TObject);
    procedure mChange(Sender: TObject);
    procedure mKeyPress(Sender: TObject; var Key: char);
    procedure mnuLtrClick(Sender: TObject);
    procedure mnuWordClick(Sender: TObject);
    procedure mnuWordLtrClick(Sender: TObject);
    procedure popCWmodeClose(Sender: TObject);
  private
    { private declarations }
    LocalDbg : boolean; // bit 4, %01000, -8 for cw routines including this form
    Switch2Word   : boolean;
    WasMemoLen : integer;
    CWMode:integer;
    function PassedKey(key:char):boolean;
    procedure blocksend;
    procedure SetSpeedChange(change:integer);
  public
    { public declarations }
    procedure UpdateTop;
  end; 

var
  frmCWType: TfrmCWType;

implementation
{$R *.lfm}

{ TfrmCWType }
uses fTRXControl,fNewQSO,dUtils,dData, uMyIni, fContest;

procedure TfrmCWType.UpdateTop;
Begin
 frmCWType.Caption:='CW Type: '+frmNewQSO.sbNewQSO.Panels[4].Text+CWTypeMode[CWMode];
end;

function TfrmCWType.PassedKey(key:char):boolean;
Begin
   PassedKey := (
     (key in ['A'..'Z']) or (key in ['0'..'9']) or (key = '=') or
     (key = '?') or (key = ',') or (key='.') or (key='/') or (key = ' ') or
     (key = '<') or (key = '>') or (key = ':') or (key = ')') or (key = '(') or
     (key = ';') or (key = '@') or (key = 'ß') or (key ='Ü') or (key ='Ö') or
     (key = 'Ä') or (key ='^')
     );
end;

procedure TfrmCWType.btnClearClick(Sender: TObject);
begin
  m.Clear;
  WasMemoLen := length(m.lines.text);
  Switch2Word := false;
  m.SetFocus;
end;

procedure TfrmCWType.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var f:integer;
begin
  popCWmodeClose(nil);
  dmUtils.SaveWindowPos(frmCWType)
end;

procedure TfrmCWType.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
   VK_F1 .. VK_F10 : frmNewQSO.FormKeyDown(Sender,Key,Shift);
   33              : Begin
                      SetSpeedChange(cqrini.ReadInteger('CW','SpeedStep', 2));
                      Key:=0;
                     end;
   34              : Begin
                      SetSpeedChange(-1*cqrini.ReadInteger('CW','SpeedStep', 2));
                      Key:=0;
                     end;
   VK_ESCAPE       : Begin
                      frmNewQSO.CWint.StopSending;
                      Key:=0;
                     end;
   end;
end;

procedure TfrmCWType.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key >= VK_F1) and (Key <= VK_F10) and (Shift = []) then
                    begin
                      frmNewQSO.FormKeyUp(Sender,Key,Shift);
                      key:=0;
                    end;
end;

procedure TfrmCWType.btnF1MouseEnter(Sender: TObject);
begin
  frmCWType.lblToShowMouseOverText.Caption:=dmUtils.GetCWMessage('F1',frmNewQSO.edtCall.Text,
      frmNewQSO.edtHisRST.Text, frmNewQSO.edtContestSerialSent.Text,frmNewQSO.edtContestExchangeMessageSent.Text,
      frmNewQSO.edtContestSerialReceived.Text,frmNewQSO.edtContestExchangeMessageReceived.Text,
      frmNewQSO.edtName.Text,frmNewQSO.lblGreeting.Caption,'');
end;

procedure TfrmCWType.btnF1MouseLeave(Sender: TObject);
begin
  frmCWType.lblToShowMouseOverText.Caption:='';
end;

procedure TfrmCWType.btnF2Click(Sender: TObject);
begin
  m.SetFocus; //after click focus back to memo
  if Assigned(frmNewQSO.CWint) and (frmNewQSO.cmbMode.Text='CW') then
   frmNewQSO.CWint.SendText(dmUtils.GetCWMessage('F2',frmNewQSO.edtCall.Text,
      frmNewQSO.edtHisRST.Text, frmNewQSO.edtContestSerialSent.Text,frmNewQSO.edtContestExchangeMessageSent.Text,
      frmNewQSO.edtContestSerialReceived.Text,frmNewQSO.edtContestExchangeMessageReceived.Text,
      frmNewQSO.edtName.Text,frmNewQSO.lblGreeting.Caption,''))
    else ShowMessage('Radio:   Not in CW mode!'+LineEnding+'or'+LineEnding+'CW interface:   No keyer defined! ');
end;

procedure TfrmCWType.btnF10MouseEnter(Sender: TObject);
begin
  frmCWType.lblToShowMouseOverText.Caption:=dmUtils.GetCWMessage('F10',frmNewQSO.edtCall.Text,
      frmNewQSO.edtHisRST.Text, frmNewQSO.edtContestSerialSent.Text,frmNewQSO.edtContestExchangeMessageSent.Text,
      frmNewQSO.edtContestSerialReceived.Text,frmNewQSO.edtContestExchangeMessageReceived.Text,
      frmNewQSO.edtName.Text,frmNewQSO.lblGreeting.Caption,'');
end;

procedure TfrmCWType.btnF10Click(Sender: TObject);
begin
  m.SetFocus; //after click focus back to memo
  if Assigned(frmNewQSO.CWint) and (frmNewQSO.cmbMode.Text='CW') then
   frmNewQSO.CWint.SendText(dmUtils.GetCWMessage('F10',frmNewQSO.edtCall.Text,
      frmNewQSO.edtHisRST.Text, frmNewQSO.edtContestSerialSent.Text,frmNewQSO.edtContestExchangeMessageSent.Text,
      frmNewQSO.edtContestSerialReceived.Text,frmNewQSO.edtContestExchangeMessageReceived.Text,
      frmNewQSO.edtName.Text,frmNewQSO.lblGreeting.Caption,''))
    else ShowMessage('Radio:   Not in CW mode!'+LineEnding+'or'+LineEnding+'CW interface:   No keyer defined! ');
end;

procedure TfrmCWType.btnF10MouseLeave(Sender: TObject);
begin
  frmCWType.lblToShowMouseOverText.Caption:='';
end;

procedure TfrmCWType.btnF1Click(Sender: TObject);
begin
  m.SetFocus; //after click focus back to memo
  if Assigned(frmNewQSO.CWint) and (frmNewQSO.cmbMode.Text='CW') then
     begin
      frmNewQSO.CWint.SendText(dmUtils.GetCWMessage('F1',frmNewQSO.edtCall.Text,
      frmNewQSO.edtHisRST.Text, frmNewQSO.edtContestSerialSent.Text,frmNewQSO.edtContestExchangeMessageSent.Text,
      frmNewQSO.edtContestSerialReceived.Text,frmNewQSO.edtContestExchangeMessageReceived.Text,
      frmNewQSO.edtName.Text,frmNewQSO.lblGreeting.Caption,''));
      if frmContest.Showing then  //set the "lastCqFreq" @contest window
        Begin
          frmContest.lblCqMode.Caption:=frmTRXControl.GetRawMode;
          frmContest.lblCqFreq.Caption := FormatFloat('0.00',frmTRXControl.GetFreqkHz);
        end;
     end
    else ShowMessage('Radio:   Not in CW mode!'+LineEnding+'or'+LineEnding+'CW interface:   No keyer defined! ');
end;

procedure TfrmCWType.btnF2MouseEnter(Sender: TObject);
begin
  frmCWType.lblToShowMouseOverText.Caption:=dmUtils.GetCWMessage('F2',frmNewQSO.edtCall.Text,
      frmNewQSO.edtHisRST.Text, frmNewQSO.edtContestSerialSent.Text,frmNewQSO.edtContestExchangeMessageSent.Text,
      frmNewQSO.edtContestSerialReceived.Text,frmNewQSO.edtContestExchangeMessageReceived.Text,
      frmNewQSO.edtName.Text,frmNewQSO.lblGreeting.Caption,'');
end;

procedure TfrmCWType.btnF2MouseLeave(Sender: TObject);
begin
  frmCWType.lblToShowMouseOverText.Caption:='';
end;

procedure TfrmCWType.btnF3Click(Sender: TObject);
begin
  m.SetFocus; //after click focus back to memo
  if Assigned(frmNewQSO.CWint) and (frmNewQSO.cmbMode.Text='CW') then
   frmNewQSO.CWint.SendText(dmUtils.GetCWMessage('F3',frmNewQSO.edtCall.Text,
      frmNewQSO.edtHisRST.Text, frmNewQSO.edtContestSerialSent.Text,frmNewQSO.edtContestExchangeMessageSent.Text,
      frmNewQSO.edtContestSerialReceived.Text,frmNewQSO.edtContestExchangeMessageReceived.Text,
      frmNewQSO.edtName.Text,frmNewQSO.lblGreeting.Caption,''))
    else ShowMessage('Radio:   Not in CW mode!'+LineEnding+'or'+LineEnding+'CW interface:   No keyer defined! ');
end;

procedure TfrmCWType.btnF3MouseEnter(Sender: TObject);
begin
  frmCWType.lblToShowMouseOverText.Caption:=dmUtils.GetCWMessage('F3',frmNewQSO.edtCall.Text,
       frmNewQSO.edtHisRST.Text, frmNewQSO.edtContestSerialSent.Text,frmNewQSO.edtContestExchangeMessageSent.Text,
       frmNewQSO.edtContestSerialReceived.Text,frmNewQSO.edtContestExchangeMessageReceived.Text,
      frmNewQSO.edtName.Text,frmNewQSO.lblGreeting.Caption,'');
end;

procedure TfrmCWType.btnF3MouseLeave(Sender: TObject);
begin
  frmCWType.lblToShowMouseOverText.Caption:='';
end;

procedure TfrmCWType.btnF4Click(Sender: TObject);
begin
  m.SetFocus; //after click focus back to memo
  if Assigned(frmNewQSO.CWint) and (frmNewQSO.cmbMode.Text='CW') then
   frmNewQSO.CWint.SendText(dmUtils.GetCWMessage('F4',frmNewQSO.edtCall.Text,
      frmNewQSO.edtHisRST.Text, frmNewQSO.edtContestSerialSent.Text,frmNewQSO.edtContestExchangeMessageSent.Text,
      frmNewQSO.edtContestSerialReceived.Text,frmNewQSO.edtContestExchangeMessageReceived.Text,
      frmNewQSO.edtName.Text,frmNewQSO.lblGreeting.Caption,''))
    else ShowMessage('Radio:   Not in CW mode!'+LineEnding+'or'+LineEnding+'CW interface:   No keyer defined! ');
end;

procedure TfrmCWType.btnF4MouseEnter(Sender: TObject);
begin
  frmCWType.lblToShowMouseOverText.Caption:=dmUtils.GetCWMessage('F4',frmNewQSO.edtCall.Text,
      frmNewQSO.edtHisRST.Text, frmNewQSO.edtContestSerialSent.Text,frmNewQSO.edtContestExchangeMessageSent.Text,
      frmNewQSO.edtContestSerialReceived.Text,frmNewQSO.edtContestExchangeMessageReceived.Text,
      frmNewQSO.edtName.Text,frmNewQSO.lblGreeting.Caption,'');
end;

procedure TfrmCWType.btnF4MouseLeave(Sender: TObject);
begin
  frmCWType.lblToShowMouseOverText.Caption:='';
end;

procedure TfrmCWType.btnF5Click(Sender: TObject);
begin
  m.SetFocus; //after click focus back to memo
  if Assigned(frmNewQSO.CWint) and (frmNewQSO.cmbMode.Text='CW') then
   frmNewQSO.CWint.SendText(dmUtils.GetCWMessage('F5',frmNewQSO.edtCall.Text,
      frmNewQSO.edtHisRST.Text, frmNewQSO.edtContestSerialSent.Text,frmNewQSO.edtContestExchangeMessageSent.Text,
      frmNewQSO.edtContestSerialReceived.Text,frmNewQSO.edtContestExchangeMessageReceived.Text,
      frmNewQSO.edtName.Text,frmNewQSO.lblGreeting.Caption,''))
    else ShowMessage('Radio:   Not in CW mode!'+LineEnding+'or'+LineEnding+'CW interface:   No keyer defined! ');
end;

procedure TfrmCWType.btnF5MouseEnter(Sender: TObject);
begin
  frmCWType.lblToShowMouseOverText.Caption:=dmUtils.GetCWMessage('F5',frmNewQSO.edtCall.Text,
      frmNewQSO.edtHisRST.Text, frmNewQSO.edtContestSerialSent.Text,frmNewQSO.edtContestExchangeMessageSent.Text,
      frmNewQSO.edtContestSerialReceived.Text,frmNewQSO.edtContestExchangeMessageReceived.Text,
      frmNewQSO.edtName.Text,frmNewQSO.lblGreeting.Caption,'');
end;

procedure TfrmCWType.btnF5MouseLeave(Sender: TObject);
begin
  frmCWType.lblToShowMouseOverText.Caption:='';
end;

procedure TfrmCWType.btnF6Click(Sender: TObject);
begin
  m.SetFocus; //after click focus back to memo
  if Assigned(frmNewQSO.CWint) and (frmNewQSO.cmbMode.Text='CW') then
   frmNewQSO.CWint.SendText(dmUtils.GetCWMessage('F6',frmNewQSO.edtCall.Text,
      frmNewQSO.edtHisRST.Text, frmNewQSO.edtContestSerialSent.Text,frmNewQSO.edtContestExchangeMessageSent.Text,
      frmNewQSO.edtContestSerialReceived.Text,frmNewQSO.edtContestExchangeMessageReceived.Text,
      frmNewQSO.edtName.Text,frmNewQSO.lblGreeting.Caption,''))
    else ShowMessage('Radio:   Not in CW mode!'+LineEnding+'or'+LineEnding+'CW interface:   No keyer defined! ');
end;

procedure TfrmCWType.btnF6MouseEnter(Sender: TObject);
begin
  frmCWType.lblToShowMouseOverText.Caption:=dmUtils.GetCWMessage('F6',frmNewQSO.edtCall.Text,
      frmNewQSO.edtHisRST.Text, frmNewQSO.edtContestSerialSent.Text,frmNewQSO.edtContestExchangeMessageSent.Text,
      frmNewQSO.edtContestSerialReceived.Text,frmNewQSO.edtContestExchangeMessageReceived.Text,
      frmNewQSO.edtName.Text,frmNewQSO.lblGreeting.Caption,'');
end;

procedure TfrmCWType.btnF6MouseLeave(Sender: TObject);
begin
  frmCWType.lblToShowMouseOverText.Caption:='';
end;

procedure TfrmCWType.btnF7Click(Sender: TObject);
begin
  m.SetFocus; //after click focus back to memo
  if Assigned(frmNewQSO.CWint) and (frmNewQSO.cmbMode.Text='CW') then
   frmNewQSO.CWint.SendText(dmUtils.GetCWMessage('F7',frmNewQSO.edtCall.Text,
      frmNewQSO.edtHisRST.Text, frmNewQSO.edtContestSerialSent.Text,frmNewQSO.edtContestExchangeMessageSent.Text,
      frmNewQSO.edtContestSerialReceived.Text,frmNewQSO.edtContestExchangeMessageReceived.Text,
      frmNewQSO.edtName.Text,frmNewQSO.lblGreeting.Caption,''))
    else ShowMessage('Radio:   Not in CW mode!'+LineEnding+'or'+LineEnding+'CW interface:   No keyer defined! ');
end;

procedure TfrmCWType.btnF7MouseEnter(Sender: TObject);
begin
  frmCWType.lblToShowMouseOverText.Caption:=dmUtils.GetCWMessage('F7',frmNewQSO.edtCall.Text,
      frmNewQSO.edtHisRST.Text, frmNewQSO.edtContestSerialSent.Text,frmNewQSO.edtContestExchangeMessageSent.Text,
      frmNewQSO.edtContestSerialReceived.Text,frmNewQSO.edtContestExchangeMessageReceived.Text,
      frmNewQSO.edtName.Text,frmNewQSO.lblGreeting.Caption,'');
end;

procedure TfrmCWType.btnF7MouseLeave(Sender: TObject);
begin
  frmCWType.lblToShowMouseOverText.Caption:='';
end;

procedure TfrmCWType.btnF8Click(Sender: TObject);
begin
  m.SetFocus; //after click focus back to memo
  if Assigned(frmNewQSO.CWint) and (frmNewQSO.cmbMode.Text='CW') then
   frmNewQSO.CWint.SendText(dmUtils.GetCWMessage('F8',frmNewQSO.edtCall.Text,
      frmNewQSO.edtHisRST.Text, frmNewQSO.edtContestSerialSent.Text,frmNewQSO.edtContestExchangeMessageSent.Text,
      frmNewQSO.edtContestSerialReceived.Text,frmNewQSO.edtContestExchangeMessageReceived.Text,
      frmNewQSO.edtName.Text,frmNewQSO.lblGreeting.Caption,''))
    else ShowMessage('Radio:   Not in CW mode!'+LineEnding+'or'+LineEnding+'CW interface:   No keyer defined! ');
end;

procedure TfrmCWType.btnF8MouseEnter(Sender: TObject);
begin
  frmCWType.lblToShowMouseOverText.Caption:=dmUtils.GetCWMessage('F8',frmNewQSO.edtCall.Text,
      frmNewQSO.edtHisRST.Text, frmNewQSO.edtContestSerialSent.Text,frmNewQSO.edtContestExchangeMessageSent.Text,
      frmNewQSO.edtContestSerialReceived.Text,frmNewQSO.edtContestExchangeMessageReceived.Text,
      frmNewQSO.edtName.Text,frmNewQSO.lblGreeting.Caption,'');
end;

procedure TfrmCWType.btnF8MouseLeave(Sender: TObject);
begin
  frmCWType.lblToShowMouseOverText.Caption:='';
end;

procedure TfrmCWType.btnF9Click(Sender: TObject);
begin
  m.SetFocus; //after click focus back to memo
  if Assigned(frmNewQSO.CWint) and (frmNewQSO.cmbMode.Text='CW') then
   frmNewQSO.CWint.SendText(dmUtils.GetCWMessage('F9',frmNewQSO.edtCall.Text,
      frmNewQSO.edtHisRST.Text, frmNewQSO.edtContestSerialSent.Text,frmNewQSO.edtContestExchangeMessageSent.Text,
      frmNewQSO.edtContestSerialReceived.Text,frmNewQSO.edtContestExchangeMessageReceived.Text,
      frmNewQSO.edtName.Text,frmNewQSO.lblGreeting.Caption,''))
    else ShowMessage('Radio:   Not in CW mode!'+LineEnding+'or'+LineEnding+'CW interface:   No keyer defined! ');
end;

procedure TfrmCWType.btnF9MouseEnter(Sender: TObject);
begin
  frmCWType.lblToShowMouseOverText.Caption:=dmUtils.GetCWMessage('F9',frmNewQSO.edtCall.Text,
      frmNewQSO.edtHisRST.Text, frmNewQSO.edtContestSerialSent.Text,frmNewQSO.edtContestExchangeMessageSent.Text,
      frmNewQSO.edtContestSerialReceived.Text,frmNewQSO.edtContestExchangeMessageReceived.Text,
      frmNewQSO.edtName.Text,frmNewQSO.lblGreeting.Caption,'');
end;

procedure TfrmCWType.btnF9MouseLeave(Sender: TObject);
begin
  frmCWType.lblToShowMouseOverText.Caption:='';
end;

procedure TfrmCWType.btnPgDnClick(Sender: TObject);
begin
  SetSpeedChange(-1*cqrini.ReadInteger('CW','SpeedStep', 2));
end;

procedure TfrmCWType.btnPgDnMouseEnter(Sender: TObject);
begin
  frmCWType.lblToShowMouseOverText.Caption:='cw keyspeed -'+IntToStr(cqrini.ReadInteger('CW','SpeedStep', 2))+' wpm';
end;

procedure TfrmCWType.btnPgDnMouseLeave(Sender: TObject);
begin
  frmCWType.lblToShowMouseOverText.Caption:='';
end;

procedure TfrmCWType.btnPgUpClick(Sender: TObject);
begin
  SetSpeedChange(cqrini.ReadInteger('CW','SpeedStep', 2));
end;

procedure TfrmCWType.btnPgUpMouseEnter(Sender: TObject);
begin
  frmCWType.lblToShowMouseOverText.Caption:='cw keyspeed +'+IntToStr(cqrini.ReadInteger('CW','SpeedStep', 2))+' wpm';
end;

procedure TfrmCWType.btnPgUpMouseLeave(Sender: TObject);
begin
  frmCWType.lblToShowMouseOverText.Caption:='';
end;

procedure TfrmCWType.edtSpeedMouseLeave(Sender: TObject);
begin
   m.SetFocus; //after click focus back to memo
end;

procedure TfrmCWType.FormShow(Sender: TObject);
var
   n:string;
begin
  dmUtils.LoadWindowPos(frmCWType);
  CWMode:=  cqrini.ReadInteger('CW','Mode',1);
  case CWMode of
   0: mnuLtr.Checked:=True;
   1: mnuWordLtr.Checked:=True;
   2: mnuWord.Checked:=True;
  end;
  UpdateTop;
  fraCWKeys1.UpdateFKeyLabels;
  m.SetFocus;
  m.Clear;
  Switch2Word :=false;
  WasMemoLen := length(m.lines.text);
  n:=IntToStr(frmTRXControl.cmbRig.ItemIndex);
   //set debug rules for this form
  LocalDbg := dmData.DebugLevel >= 1 ;
  if dmData.DebugLevel < 0 then
        LocalDbg :=  LocalDbg or ((abs(dmData.DebugLevel) and 8) = 8 );
end;

procedure TfrmCWType.btnCloseClick(Sender: TObject);
begin
  Close
end;

procedure TfrmCWType.FormResize(Sender: TObject);
begin
  if frmCWType.Height<200 then
    Begin
       fraCWKeys1.Height:=(frmCWType.Height-pnlBottom.Height)div 2;
       m.Height:=(frmCWType.Height-pnlBottom.Height)div 2;
    end;
end;
procedure TfrmCWType.fraCWKeys1Resize(Sender: TObject);
 var
  w, h, l, t: word;
  i: integer;
  c: word;
begin
 with fraCWKeys1 do
  Begin
  h := Round(Height / 2) - 2;
  w := Round(Width / 6) - 2;
  t := Round(Height / 2);
  c := 0;

  for i := 0 to ComponentCount - 1 do
   begin

    if (Components[i] is TButton) then
     begin
     (Components[i] as TButton).Height := h;
      (Components[i] as TButton).Width := w;

      (Components[i] as TButton).Left := c * w + 5;
      Inc(c);
      if (Components[i] as TButton).TabOrder = 5 then
       c := 0;

      if (Components[i] as TButton).TabOrder > 5 then
        (Components[i] as TButton).Top := t
     end
   end
  end;
end;

procedure TfrmCWType.blocksend;
var
  msg :string ;
  l   : char;
  i   : integer;
Begin
  if LocalDbg then Writeln();
  if LocalDbg then Writeln('In blocksend-Len:',  length(m.lines.text),' Was:',WasMemoLen);
   msg := '';
   for i:= WasMemoLen+1 to length(m.lines.text) do
     begin
         l := Upcase( m.Lines.Text[i]);
         if (l = #$0A) then l := ' '; //convert newline to space before send
         if PassedKey(l) then  msg := msg + l;
     end;
   if msg<>'' then
    Begin
     if LocalDbg then Writeln('Blocksend out:'+msg);
     if Assigned(frmNewQSO.CWint) and (frmNewQSO.cmbMode.Text='CW') then
       frmNewQSO.CWint.SendText(msg)
      else ShowMessage('Radio:   Not in CW mode!'+LineEnding+'or'+LineEnding+'CW interface:   No keyer defined! ');
    end;
   WasMemoLen :=length(m.lines.text);
end;

procedure TfrmCWType.mChange(Sender: TObject);
var
  l   : char ;

begin
  if  ((length(m.lines.text)-WasMemoLen) < 1 ) then
        Begin
         if LocalDbg then Writeln('Change without lenght grow. DEL?');
         if LocalDbg then Writeln('Len:',  length(m.lines.text),' Was:',WasMemoLen);
         WasMemoLen :=length(m.lines.text);
        end
  else
  Begin
  if LocalDbg then Writeln('Len:',  length(m.lines.text),' Was:',WasMemoLen);
  if ( ((length(m.lines.text)-WasMemoLen) > 1 )
       and not(Switch2Word)
       and not(CWMode=2)
     ) then
     Begin
       if LocalDbg then Writeln('Pasted text, more than 1chr at same go');
       blocksend;
     end
    else  //only 1 char added
     Begin
        l := Upcase( m.Lines.Text[length(m.lines.text)]);
         if PassedKey(l) then
           begin
            if LocalDbg then Write(ord(l),'_');
            case CWMode of

                 0:               Begin
                                       if Assigned(frmNewQSO.CWint) and (frmNewQSO.cmbMode.Text='CW') then
                                         frmNewQSO.CWint.SendText(l) //letter mode
                                        else ShowMessage('Radio:   Not in CW mode!'+LineEnding+'or'+LineEnding+'CW interface:   No keyer defined! ');
                                       WasMemoLen :=length(m.lines.text);
                                  end;
                 1:               Begin  //word mode , first word is send character by character
                                   if (not Switch2Word) and (l = ' ') then
                                         Begin
                                            if LocalDbg then Writeln(' 1st word passed');
                                            Switch2Word := true;
                                         end;
                                   if Switch2Word then
                                      Begin
                                       if (l = ' ') then blocksend;
                                      end
                                    else
                                      Begin
                                      if Assigned(frmNewQSO.CWint) and (frmNewQSO.cmbMode.Text='CW') then
                                       frmNewQSO.CWint.SendText(l)
                                       else ShowMessage('Radio:   Not in CW mode!'+LineEnding+'or'+LineEnding+'CW interface:   No keyer defined! ');
                                      WasMemoLen :=length(m.lines.text);
                                      end;
                                  end;

                 2:               if (l = ' ') then blocksend; //word mode

              end; //case
           end;  //valid key
     end; //only 1 char added
 end;
  l:=#0;
end;

procedure TfrmCWType.mKeyPress(Sender: TObject; var Key: char);
begin
  if key  = #$0D then
   Begin
    blocksend;
    Switch2Word := false;
   end;
end;


procedure TfrmCWType.mnuLtrClick(Sender: TObject);
begin
  mnuLtr.Checked:=True;
  //by this way QT5 and GTK2 both work same
  CWMode:=0;
  UpdateTop;
end;

procedure TfrmCWType.mnuWordLtrClick(Sender: TObject);
begin
  mnuWordLtr.Checked:=True;
  //by this way QT5 and GTK2 both work same
  CWMode:=1;
  UpdateTop;
end;

procedure TfrmCWType.mnuWordClick(Sender: TObject);
begin
  mnuWord.Checked:=True;
  //by this way QT5 and GTK2 both work same
  CWMode:=2;
  UpdateTop;
end;

procedure TfrmCWType.popCWmodeClose(Sender: TObject);
begin
      cqrini.WriteInteger('CW','Mode',CWMode);
      m.SetFocus; //after mode change focus back to memo
end;

procedure TfrmCWType.SetSpeedChange(change:integer);
var
  speed : Integer = 0;
    n   : string;
begin
   if Assigned(frmNewQSO.CWint) then
    begin
      n:=IntToStr(frmTRXControl.cmbRig.ItemIndex);
      speed := frmNewQSO.CWint.GetSpeed+change;
      frmNewQSO.CWint.SetSpeed(speed);
      if (cqrini.ReadInteger('CW'+n,'Type',0)=1) and cqrini.ReadBool('CW'+n,'PotSpeed',False) then
       Begin
        frmNewQSO.sbNewQSO.Panels[4].Text := 'Pot WPM';
       end
      else
       begin
        frmNewQSO.sbNewQSO.Panels[4].Text := IntToStr(speed)+'WPM';
       end;
      UpdateTop;
    end;
end;

end.
