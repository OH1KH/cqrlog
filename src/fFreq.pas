unit fFreq;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, ExtCtrls, DBGrids, db, lcltype;

type

  { TfrmFreq }

  TfrmFreq = class(TForm)
    btnChange: TButton;
    btnCancel: TButton;
    btnInitFreq: TButton;
    chkNewModes: TCheckBox;
    dbgrdFreq: TDBGrid;
    dsrFreq: TDatasource;
    lblFreqNote1: TLabel;
    lblFreqNote2: TLabel;
    lblFreqNote3: TLabel;
    lblFreqNote4: TLabel;
    pnlFreq2: TPanel;
    procedure btnInitFreqClick(Sender: TObject);
    procedure chkNewModesChange(Sender: TObject);
    procedure dbgrdFreqColumnSized(Sender : TObject);
    procedure dbgrdFreqDblClick(Sender : TObject);
    procedure FormClose(Sender : TObject; var CloseAction : TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure btnChangeClick(Sender: TObject);
  private
    band: String;
    procedure RefreshData(OnlyBand : String = '');
  public
    { public declarations }
  end; 

var
  frmFreq: TfrmFreq;

implementation
{$R *.lfm}

{ TfrmFreq }
uses dData, fChangeFreq, dUtils, uMyIni;

procedure TfrmFreq.FormShow(Sender: TObject);
begin
  dmUtils.LoadWindowPos(frmFreq);
  chkNewModes.Checked:= cqrini.ReadBool('Bands', 'UseNewModeFreq',false);
  RefreshData()
end;

procedure TfrmFreq.FormClose(Sender : TObject; var CloseAction : TCloseAction);
begin
  dmUtils.SaveWindowPos(frmFreq);
  if dmData.trFreqs.Active then
    dmData.trFreqs.Rollback
end;

procedure TfrmFreq.dbgrdFreqColumnSized(Sender : TObject);
begin
  dmUtils.SaveDBGridInForm(frmFreq)
end;

procedure TfrmFreq.chkNewModesChange(Sender: TObject);
begin
  cqrini.WriteBool('Bands', 'UseNewModeFreq',chkNewModes.Checked);
  lblFreqNote1.Visible:= not chkNewModes.Checked;
  lblFreqNote2.Visible:= not chkNewModes.Checked;
  lblFreqNote3.Visible:= not chkNewModes.Checked;
  lblFreqNote4.Visible:= not chkNewModes.Checked;
  btnInitFreq.Visible:= chkNewModes.Checked;
  RefreshData();
end;

procedure TfrmFreq.btnInitFreqClick(Sender: TObject);
var s: PChar;
begin
   s:= 'Are you sure you want to REdefine all mode/freq columns'+LineEnding+
       'by default values from old mode/freq limits?'+LineEnding+
       'This will DELETE ALL YOUR PREVIOUS CHANGES'+LineEnding+LineEnding+
               'Are you REALLY SURE you want to do this?';
           if Application.MessageBox(s,'Question ...', mb_YesNo + mb_IconQuestion) = idNo then
                                                                                              exit;
   dmUtils.FillNewBandModeLimits;
   RefreshData();
end;

procedure TfrmFreq.dbgrdFreqDblClick(Sender : TObject);
begin
  btnChange.Click
end;

procedure TfrmFreq.btnChangeClick(Sender: TObject);
begin
  with TfrmChangeFreq.Create(frmFreq) do
  try
    UseNew           := cqrini.ReadBool('Bands', 'UseNewModeFreq',false);
    band             := dmData.qFreqs.Fields[1].AsString;
    edtBegin.Text    := FloatToStr(dmData.qFreqs.Fields[2].AsFloat);
    edtEnd.Text      := FloatToStr(dmData.qFreqs.Fields[3].AsFloat);
    edtCW.Text       := FloatToStr(dmData.qFreqs.Fields[4].AsFloat);
    edtData.Text     := FloatToStr(dmData.qFreqs.Fields[5].AsFloat);
    edtSSB.Text      := FloatToStr(dmData.qFreqs.Fields[6].AsFloat);
    edtRXOffset.Text := FloatToStr(dmData.qFreqs.Fields[7].AsFloat);
    edtTXOffset.Text := FloatToStr(dmData.qFreqs.Fields[8].AsFloat);

    edtB_cw.Text     := FloatToStr(dmData.qFreqs.Fields[9].AsFloat);
    edtE_cw.Text     := FloatToStr(dmData.qFreqs.Fields[10].AsFloat);
    edtB_data.Text   := FloatToStr(dmData.qFreqs.Fields[11].AsFloat);
    edtE_data.Text   := FloatToStr(dmData.qFreqs.Fields[12].AsFloat);
    edtB_ssb.Text    := FloatToStr(dmData.qFreqs.Fields[13].AsFloat);
    edtE_ssb.Text    := FloatToStr(dmData.qFreqs.Fields[14].AsFloat);
    edtB_am.Text     := FloatToStr(dmData.qFreqs.Fields[15].AsFloat);
    edtE_am.Text     := FloatToStr(dmData.qFreqs.Fields[16].AsFloat);
    edtB_fm.Text     := FloatToStr(dmData.qFreqs.Fields[17].AsFloat);
    edtE_fm.Text     := FloatToStr(dmData.qFreqs.Fields[18].AsFloat);
    Caption:='Change '+band+' band`s frequencies (all in Mhz)';
    ShowModal;

    if ModalResult = mrOK then
    begin
      dmData.SaveBandChanges(
                             band,
                             StrToFloat(edtBegin.Text),
                             StrToFloat(edtEnd.Text),
                             StrToFloat(edtCW.Text),
                             StrToFloat(edtData.Text),
                             StrToFloat(edtSSB.Text),
                             StrToFloat(edtRXOffset.Text),
                             StrToFloat(edtTXOffset.Text),
                             StrToFloat(edtB_cw.Text),
                             StrToFloat(edtE_cw.Text),
                             StrToFloat(edtB_data.Text),
                             StrToFloat(edtE_data.Text),
                             StrToFloat(edtB_ssb.Text),
                             StrToFloat(edtE_ssb.Text),
                             StrToFloat(edtB_am.Text),
                             StrToFloat(edtE_am.Text),
                             StrToFloat(edtB_fm.Text),
                             StrToFloat(edtE_fm.Text));
    end
  finally
    Free;
    RefreshData(band)
  end
end;

procedure TfrmFreq.RefreshData(OnlyBand : String = '');
const
  C_SEL = 'SELECT * FROM cqrlog_common.bands ORDER BY b_begin';
var
  i : Integer;
begin
  if dmData.trFreqs.Active then
    dmData.trFreqs.Rollback;

  dmData.qFreqs.SQL.Text := C_SEL;
  dmData.trFreqs.StartTransaction;
  dmData.qFreqs.Open;

  dbgrdFreq.Columns[0].Visible := False;

  if (OnlyBand<>'') then
  begin
    dmData.qFreqs.DisableControls;
    try
      dmData.qFreqs.First;
      while not dmData.qFreqs.Eof do
      begin
        if (dmData.qFreqs.Fields[1].AsString=OnlyBand) then
          break
        else
          dmData.qFreqs.Next
      end
    finally
      dmData.qFreqs.EnableControls
    end
  end;

  dmUtils.LoadDBGridInForm(frmFreq);
  dbgrdFreq.Columns[1].Title.Caption := 'Band';
  dbgrdFreq.Columns[2].Title.Caption := 'Begin';
  dbgrdFreq.Columns[3].Title.Caption := 'End';
  dbgrdFreq.Columns[4].Title.Caption := 'CW';
  dbgrdFreq.Columns[5].Title.Caption := 'Data';
  dbgrdFreq.Columns[6].Title.Caption := 'SSB';
  dbgrdFreq.Columns[7].Title.Caption := 'RX offset';
  dbgrdFreq.Columns[8].Title.Caption := 'TX offset';
  dbgrdFreq.Columns[9].Title.Caption := 'CW Begin';
  dbgrdFreq.Columns[10].Title.Caption := 'CW End';
  dbgrdFreq.Columns[11].Title.Caption := 'Data Begin';
  dbgrdFreq.Columns[12].Title.Caption := 'Data End';
  dbgrdFreq.Columns[13].Title.Caption := 'SSB Begin';
  dbgrdFreq.Columns[14].Title.Caption := 'SSB End';
  dbgrdFreq.Columns[15].Title.Caption := 'AM Begin';
  dbgrdFreq.Columns[16].Title.Caption := 'AM End';
  dbgrdFreq.Columns[17].Title.Caption := 'FM Begin';
  dbgrdFreq.Columns[18].Title.Caption := 'FM End';

  for i:=2 to dbgrdFreq.Columns.Count-1 do
    dbgrdFreq.Columns[i].DisplayFormat   := '####0.000;;';

  if chkNewModes.Checked then
    for i:=2 to 6 do
       dbgrdFreq.Columns[i].Visible := False
   else
     for i:=9 to dbgrdFreq.Columns.Count-1 do
       dbgrdFreq.Columns[i].Visible := False;


end;

end.

