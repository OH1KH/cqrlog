unit fChangeFreq;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, lcltype, ExtCtrls;

type

  { TfrmChangeFreq }

  TfrmChangeFreq = class(TForm)
    blCWEnd: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
    edtBegin: TEdit;
    edtB_am: TEdit;
    edtB_cw: TEdit;
    edtB_data: TEdit;
    edtB_fm: TEdit;
    edtB_ssb: TEdit;
    edtCW: TEdit;
    edtE_am: TEdit;
    edtData: TEdit;
    edtEnd: TEdit;
    edtE_cw: TEdit;
    edtE_data: TEdit;
    edtE_fm: TEdit;
    edtE_ssb: TEdit;
    edtRXOffset: TEdit;
    edtSSB: TEdit;
    edtTXOffset: TEdit;
    lblBlindAnhor: TLabel;
    lblAmBegin: TLabel;
    lblAmEnd: TLabel;
    lblCw: TLabel;
    lblCWBegin: TLabel;
    lblData: TLabel;
    lblDataBegin: TLabel;
    lblDataEnd: TLabel;
    lblFmBegin: TLabel;
    lblFmEnd: TLabel;
    lblFreqNote1: TLabel;
    lblFreqNote2: TLabel;
    lblFreqNote3: TLabel;
    lblFreqNote4: TLabel;
    lblSsb: TLabel;
    lblBBegin: TLabel;
    lblBEnd: TLabel;
    lblRXOff : TLabel;
    lblSsbBegin: TLabel;
    lblSsbEnd: TLabel;
    lblTXoff : TLabel;
    pnlOldHelp: TPanel;
    pnlOld: TPanel;
    pnlNew: TPanel;
    procedure btnOKClick(Sender: TObject);
    procedure ChkKeyPress(Sender: TObject; var Key: char);
    procedure edtBeginEnter(Sender: TObject);
    procedure edtBeginExit(Sender: TObject);
    procedure edtB_cwExit(Sender: TObject);
    procedure edtCWExit(Sender: TObject);
    procedure edtE_cwExit(Sender: TObject);
    procedure FormShow(Sender: TObject);

  private
    { private declarations }
    procedure NoModeUsed(Sender: TObject);
  public
    { public declarations }
    band   :String;
    UseNew :Boolean;
  end; 

var
  frmChangeFreq: TfrmChangeFreq;
  editErrors: TstringList;

implementation
{$R *.lfm}

uses uMyIni;

{ TfrmChangeFreq }

procedure TfrmChangeFreq.ChkKeyPress(Sender: TObject; var Key: char);
begin
  if (not (Key in ['0'..'9', '.','-','+', #8, #127])) OR ( (Key = '.') and (pos('.',TEdit(Sender).Text)>0) ) then Key := #0;
end;

procedure TfrmChangeFreq.NoModeUsed(Sender: TObject);
Begin
  case (Sender as TEdit).Name of
  'edtB_cw'     : if edtE_cw.Text<>'0' then edtE_cw.Text:='0';
  'edtB_data'   : if edtE_data.Text<>'0' then edtE_data.Text:='0';
  'edtB_ssb'    : if edtE_ssb.Text<>'0' then edtE_ssb.Text:='0';
  'edtB_am'     : if edtE_am.Text<>'0' then edtE_am.Text:='0';
  'edtB_fm'     : if edtE_fm.Text<>'0' then edtE_fm.Text:='0';
  'edtE_cw'     : if edtB_cw.Text<>'0' then edtB_cw.Text:='0';
  'edtE_data'   : if edtB_data.Text<>'0' then edtB_data.Text:='0';
  'edtE_ssb'    : if edtB_ssb.Text<>'0' then edtB_ssb.Text:='0';
  'edtE_am'     : if edtB_am.Text<>'0' then edtB_am.Text:='0';
  'edtE_fm'     : if edtB_fm.Text<>'0' then edtB_fm.Text:='0';
  end;
end;

procedure TfrmChangeFreq.edtBeginEnter(Sender: TObject);  //used for all TEdits
var       i:integer;
begin
  (Sender as TEdit).Font.Color:=clDefault;
  (Sender as TEdit).Refresh;
  if  editErrors.Count>0 then
   begin;
    if editErrors.Find((Sender as TEdit).Name,i) then
      editErrors.Delete(i);
   end;
end;

procedure TfrmChangeFreq.edtBeginExit(Sender: TObject);
//this can be used for band begin, band end, rxoffset and txoffset to validate entered value.
var b,f:currency;
begin
 if NOT TryStrToCurr((Sender as TEdit).Text,f) then
  begin
    Application.MessageBox('You must enter correct frequency!','Error',mb_OK+mb_IconError);
     (Sender as TEdit).Font.Color:=clRed;
     (Sender as TEdit).Refresh;
     editErrors.Add((Sender as TEdit).Name);
    exit
  end;
 if (((Sender as TEdit).Name='edtBegin') and (f<=0)) then
      Begin
       Application.MessageBox('Band start must be greater than zero MHz','Error',mb_OK+mb_IconError);
       (Sender as TEdit).Font.Color:=clRed;
       (Sender as TEdit).Refresh;
       editErrors.Add((Sender as TEdit).Name);
       exit;
      end;
  if ((Sender as TEdit).Name='edtEnd') then
       Begin
          TryStrToCurr(edtBegin.Text,b); //assume Band begin is ok without checking
          if (f<b) then
           Begin
            Application.MessageBox('Band end must be greater than Band begin value','Error',mb_OK+mb_IconError);
             (Sender as TEdit).Font.Color:=clRed;
             (Sender as TEdit).Refresh;
             editErrors.Add((Sender as TEdit).Name);
            exit;
           end;
         end;
end;

procedure TfrmChangeFreq.edtB_cwExit(Sender: TObject);
//this can be used to all new begin values  to validate entered value.
var b,e,f:currency;
begin
   if not UseNew then exit;
   if NOT TryStrToCurr((Sender as TEdit).Text,f) then
  begin
    Application.MessageBox('You must enter correct frequency!','Error',mb_OK+mb_IconError);
     (Sender as TEdit).Font.Color:=clRed;
     (Sender as TEdit).Refresh;
     editErrors.Add((Sender as TEdit).Name);
    exit
  end;

  if (f=0) then //special case, means that mode is not used in band
   Begin
    NoModeUsed(Sender);
    exit
   end;

  TryStrToCurr(edtBegin.Text,b); //assume Band begin is ok without checking
  TryStrToCurr(edtEnd.Text,e); //assume Band end is ok without checking
  if ((f<b) or (f>e)) then
  begin
    Application.MessageBox('Value must be within band Begin and end!','Error',mb_OK+mb_IconError);
     (Sender as TEdit).Font.Color:=clRed;
     (Sender as TEdit).Refresh;
     editErrors.Add((Sender as TEdit).Name);
    exit
  end;

end;

procedure TfrmChangeFreq.edtCWExit(Sender: TObject);
//this can be used for (old) cw, data, ssb to validate entered value.
var b,e,f:currency;
begin
   if UseNew then exit;

  if NOT TryStrToCurr((Sender as TEdit).Text,f) then
  begin
    Application.MessageBox('You must enter correct frequency!','Error',mb_OK+mb_IconError);
     (Sender as TEdit).Font.Color:=clRed;
     (Sender as TEdit).Refresh;
     editErrors.Add((Sender as TEdit).Name);
    exit
  end;

  TryStrToCurr(edtBegin.Text,b); //assume Band begin is ok without checking
  TryStrToCurr(edtEnd.Text,e); //assume Band end is ok without checking
  if ((f<b) or (f>e)) then
  begin
    Application.MessageBox('Value must be within band Begin and end!','Error',mb_OK+mb_IconError);
     (Sender as TEdit).Font.Color:=clRed;
     (Sender as TEdit).Refresh;
     editErrors.Add((Sender as TEdit).Name);
    exit
  end;

  if ((Sender as TEdit).Name='edtData') then
   Begin
     TryStrToCurr(edtSSB.Text,e); //assume Ssb is ok without checking
     if ((f<b) or (f>=e)) then
      begin
        Application.MessageBox('Value must greater band Begin less than SSB','Error',mb_OK+mb_IconError);
         (Sender as TEdit).Font.Color:=clRed;
         (Sender as TEdit).Refresh;
         editErrors.Add((Sender as TEdit).Name);
        exit
      end;
   end;

  if ((Sender as TEdit).Name='edtSSB') then
   Begin
     TryStrToCurr(edtEnd.Text,e); //assume Band begin is ok without checking
     if ((f<b) or (f>=e)) then
      begin
        Application.MessageBox('Value must greater than DATA and less than Band end','Error',mb_OK+mb_IconError);
         (Sender as TEdit).Font.Color:=clRed;
         (Sender as TEdit).Refresh;
         editErrors.Add((Sender as TEdit).Name);
        exit
      end;
   end;

end;

procedure TfrmChangeFreq.edtE_cwExit(Sender: TObject);
//this can be used to all new end values  to validate entered value.
var b,e,f :currency;
    err   :boolean;
begin
   if not UseNew then exit;
   if NOT TryStrToCurr((Sender as TEdit).Text,f) then
  begin
    Application.MessageBox('You must enter correct frequency!','Error',mb_OK+mb_IconError);
     (Sender as TEdit).Font.Color:=clRed;
     (Sender as TEdit).Refresh;
     editErrors.Add((Sender as TEdit).Name);
    exit
  end;

   if (f=0) then //special case, means that mode is not used in band
   Begin
    NoModeUsed(Sender);  //set corresponding begin or end also zero
    exit
   end;

  TryStrToCurr(edtBegin.Text,b); //assume Band begin is ok without checking
  TryStrToCurr(edtEnd.Text,e); //assume Band end is ok without checking
  if ((f<b) or (f>e)) then
  begin
    Application.MessageBox('Value must be within band Begin and end!','Error',mb_OK+mb_IconError);
     (Sender as TEdit).Font.Color:=clRed;
     (Sender as TEdit).Refresh;
     editErrors.Add((Sender as TEdit).Name);
    exit
  end;

  err:=false;

  case (Sender as TEdit).Name of
  'edtE_cw'     : Begin
                   TryStrToCurr(edtB_cw.Text,b);
                   err:=(f<b);
                 end;
  'edtE_data'   : Begin
                   TryStrToCurr(edtB_data.Text,b);
                   err:=(f<b);
                 end;
  'edtE_ssb'    : Begin
                   TryStrToCurr(edtB_ssb.Text,b);
                   err:=(f<b);
                 end;
  'edtE_am'     : Begin
                   TryStrToCurr(edtB_am.Text,b);
                   err:=(f<b);
                 end;
  'edtE_fm'     : Begin
                   TryStrToCurr(edtB_fm.Text,b);
                   err:=(f<b);
                 end;
  end;

  if err then
   begin
     Application.MessageBox('Value must be bigger that start value!','Error',mb_OK+mb_IconError);
     (Sender as TEdit).Font.Color:=clRed;
     (Sender as TEdit).Refresh;
     editErrors.Add((Sender as TEdit).Name);
     exit
   end;

end;

procedure TfrmChangeFreq.FormShow(Sender: TObject);

begin
  pnlNew.Visible:= UseNew;
  pnlOld.Visible:= not UseNew;
  pnlOldHelp.Visible:= not UseNew;
  editErrors:=TStringList.Create();
  editErrors.Sorted:=True;
  editErrors.Duplicates:=dupIgnore;
end;

procedure TfrmChangeFreq.btnOKClick(Sender: TObject);
var
  i,c : integer;
  e   : String = 'There are ';
begin
  if  editErrors.Count>0 then
   Begin
     e:=e+IntToStr(editErrors.Count)+' error(s) in:'+LineEnding;
     for i:=0 to editErrors.Count-1 do
       e:=e+editErrors[i]+LineEnding;
     e:=e+'Please fix!';
     Application.MessageBox(PChar(e),'Error',mb_OK+mb_IconError);
     exit;
   end;
  editErrors.Free;
  ModalResult := mrOK;
end;


end.

