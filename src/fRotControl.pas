unit fRotControl;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, uMyIni, uRotControl, fNewQSO, LCLType, ComCtrls, Menus,
  EditBtn, Types, StrUtils;

type

  { TfrmRotControl }

  TfrmRotControl = class(TForm)
    btnLeft: TButton;
    btnLongP: TButton;
    btnRight: TButton;
    btnShortP: TButton;
    btnStop: TButton;
    edtAzimuth: TEdit;
    gbAzimuth: TGroupBox;
    lblAzimuth: TLabel;
    lblAzmax: TLabel;
    lblAzmin: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    mnuMinMax: TMenuItem;
    mnuDirbtns: TMenuItem;
    mnuStopbtn: TMenuItem;
    mnuPreferences: TMenuItem;
    pbAz: TProgressBar;
    pnlMinMax: TPanel;
    pnlBtns: TPanel;
    rbRotor1: TRadioButton;
    rbRotor2: TRadioButton;
    tmrStopRot: TTimer;
    tmrRotor: TTimer;
    procedure btnLeftClick(Sender: TObject);
    procedure btnRightClick(Sender: TObject);
    procedure btnShortPClick(Sender: TObject);
    procedure btnLongPClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure edtAzimuthKeyPress(Sender: TObject; var Key: char);
    procedure edtAzimuthKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure edtAzimuthMouseLeave(Sender: TObject);
    procedure edtAzimuthMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtAzimuthMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure gbAzimuthClick(Sender: TObject);
    procedure mnuDirbtnsClick(Sender: TObject);
    procedure mnuMinMaxClick(Sender: TObject);
    procedure mnuPreferencesClick(Sender: TObject);
    procedure mnuStopbtnClick(Sender: TObject);
    procedure rbRotor1Click(Sender: TObject);
    procedure rbRotor2Click(Sender: TObject);
    procedure tmrRotorTimer(Sender: TObject);
    procedure tmrStopRotTimer(Sender: TObject);
  private
    { private declarations }
    rotor : TRotControl;
    MouseWheelUsed : Boolean;
    CaretMousePos  : integer;
  public
    { public declarations }
    BeamDir : Double;
    procedure SynROT;
    function  InicializeRot : Boolean;
    procedure UpdateAZdisp(Az,AzMin,AzMax:Double;UseState:Boolean);
  end;

var
  frmRotControl: TfrmRotControl;

implementation
{$R *.lfm}

{ TfrmRotControl }

uses dUtils, dData, fGrayline;

procedure TfrmRotControl.FormShow(Sender: TObject);
begin
  dmUtils.LoadWindowPos(frmRotControl);
  rbRotor1.Caption := cqrini.ReadString('ROT1','Desc','Rotor 1');
  rbRotor2.Caption := cqrini.ReadString('ROT2','Desc','Rotor 2');
  btnLeft.Visible:=cqrini.ReadBool('ROT','DirBtns',False);
  btnRight.Visible:=cqrini.ReadBool('ROT','DirBtns',False);
  mnuDirBtns.Checked:=cqrini.ReadBool('ROT','DirBtns',False);;
  pnlMinMax.Visible:=cqrini.ReadBool('ROT','MinMax',False);
  mnuMinMax.Checked:=cqrini.ReadBool('ROT','MinMax',False);;
  btnStop.Visible:=cqrini.ReadBool('ROT','Stopbtn',False);
  mnuStopbtn.Checked:=cqrini.ReadBool('ROT','Stopbtn',False);
  if pnlMinMax.Visible then gbAzimuth.Height:=70;
  Beamdir:=-1;
end;

procedure TfrmRotControl.gbAzimuthClick(Sender: TObject);
var
  i:Extended;
begin
  TryStrToFloat(lblAzimuth.Caption,i);
  edtAzimuth.Text       := FormatFloat('000',i);
  CaretMousePos         := length(edtAzimuth.Text);
  edtAzimuth.Font       := lblAzimuth.Font;
  edtAzimuth.Color      := clYellow;
  edtAzimuth.Visible    := true;
  edtAzimuth.Repaint;
  edtAzimuth.SetFocus;
end;

procedure TfrmRotControl.mnuDirbtnsClick(Sender: TObject);
begin
   mnuDirbtns.Checked:= not mnuDirbtns.Checked;
   btnLeft.Visible:=mnuDirbtns.Checked;
   btnRight.Visible:=mnuDirbtns.Checked;
   cqrini.WriteBool('ROT','DirBtns',mnuDirbtns.Checked);
end;

procedure TfrmRotControl.mnuMinMaxClick(Sender: TObject);
begin
  mnuMinMax.Checked:= not mnuMinMax.Checked;
  if mnuMinMax.Checked then gbAzimuth.Height:=70 else gbAzimuth.Height:=50;
  pnlMinMax.Visible:=mnuMinMax.Checked;
  cqrini.WriteBool('ROT','MinMax',pnlMinMax.Visible);
end;

procedure TfrmRotControl.mnuPreferencesClick(Sender: TObject);
begin
  cqrini.WriteInteger('Pref', 'ActPageIdx', 6);  //set RotConrol tab active. Number may change if preferences page change
  frmNewQSO.acPreferences.Execute
end;

procedure TfrmRotControl.mnuStopbtnClick(Sender: TObject);
begin
  mnuStopbtn.Checked:= not  mnuStopbtn.Checked;
  btnStop.Visible:=mnuStopbtn.Checked;
  cqrini.WriteBool('ROT','Stopbtn',btnStop.Visible);
end;

procedure TfrmRotControl.rbRotor1Click(Sender: TObject);
begin
  cqrini.WriteBool('ROT','Use1',rbRotor1.Checked);
  InicializeRot
end;

procedure TfrmRotControl.rbRotor2Click(Sender: TObject);
begin
  cqrini.WriteBool('ROT','Use1',rbRotor1.Checked);
  InicializeRot
end;

procedure TfrmRotControl.tmrRotorTimer(Sender: TObject);
begin
  SynROT
end;

procedure TfrmRotControl.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
   dmUtils.SaveWindowPos(frmRotControl);
end;

procedure TfrmRotControl.FormDestroy(Sender: TObject);
begin
  if Assigned(rotor) then
       FreeAndNil(rotor)
end;

procedure TfrmRotControl.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key= VK_ESCAPE) then
  begin
    frmNewQSO.ReturnToNewQSO;
    key := 0
  end
end;

procedure TfrmRotControl.btnShortPClick(Sender: TObject);
begin
   if fNewQSO.Azimuth<>'' then
      rotor.SetAzimuth(fNewQSO.Azimuth)
end;
procedure TfrmRotControl.btnLongPClick(Sender: TObject);
var
    LAzimuth : String = '';
    SAz : Double = 0 ;
    LAz : Double = 0 ;
begin
   if fNewQSO.Azimuth<>'' then
   begin
     SAz := StrToFloat(fNewQSO.Azimuth);
     if SAz >180 then
        LAz := SAz - 180
     else
        LAz := SAz + 180;
     Lazimuth := FloatToStr(LAz);
     rotor.SetAzimuth(LAzimuth)
   end;
end;
procedure TfrmRotControl.btnLeftClick(Sender: TObject);
begin
   rotor.StopRot;
   tmrStopRot.Enabled:=False;
   sleep(100);
   Application.ProcessMessages;
   rotor.LeftRot;
   tmrStopRot.Enabled:=True;
   btnLeft.Font.Color:=clGreen;
   btnLeft.Font.Style:=btnLeft.Font.Style+[fsBold];
   btnLeft.Repaint;
   btnRight.Font.Color:=clDefault;
   btnRight.Font.Style:=btnRight.Font.Style-[fsBold];
   btnRight.Repaint;
end;

procedure TfrmRotControl.btnRightClick(Sender: TObject);
begin
   rotor.StopRot;
   tmrStopRot.Enabled:=False;
   sleep(100);
   Application.ProcessMessages;
   rotor.RightRot;
   tmrStopRot.Enabled:=True;
   btnRight.Font.Color:=clGreen;
   btnRight.Font.Style:=btnRight.Font.Style+[fsBold];
   btnRight.Repaint;
   btnLeft.Font.Color:=clDefault;
   btnLeft.Font.Style:=btnLeft.Font.Style-[fsBold];
   btnLeft.Repaint;
end;

procedure TfrmRotControl.btnStopClick(Sender: TObject);
begin
  btnStop.Font.Color:=clRed;
  btnStop.Font.Style:=btnStop.Font.Style+[fsBold];
  btnStop.Repaint;

  tmrStopRot.Enabled:=False;
  rotor.StopRot;
  btnLeft.Font.Color:=clDefault;
  btnLeft.Font.Style:=btnLeft.Font.Style-[fsBold];
  btnLeft.Repaint;
  btnRight.Font.Color:=clDefault;
  btnRight.Font.Style:=btnRight.Font.Style-[fsBold];
  btnRight.Repaint;
  Application.ProcessMessages;
  sleep(300);
  Application.ProcessMessages;
  btnStop.Font.Color:=clDefault;
  btnStop.Font.Style:=btnStop.Font.Style-[fsBold];
  btnStop.Repaint;
end;


procedure TfrmRotControl.edtAzimuthKeyPress(Sender: TObject; var Key: char);
var
   a : integer;
begin
  if (Key<>#127)      //delete and numbers ok
    and ((Key >'9')
       or (( Key>=#20) and (Key<'0'))) then
                                        Key:=#0;
   if TryStrToInt(edtAzimuth.Text,a) then
     Begin
       if a > 360 then a:=360;
       if a < 0 then a:=0;
       edtAzimuth.Text:=IntToStr(a);
     end;
end;

procedure TfrmRotControl.edtAzimuthKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if Key = VK_Return then
   Begin
    MouseWheelUsed:=false;
    if edtAzimuth.Text<>'' then
      rotor.SetAzimuth(edtAzimuth.Text);
    edtAzimuth.Visible:=False;
   end;
end;

procedure TfrmRotControl.edtAzimuthMouseLeave(Sender: TObject);
begin
  if MouseWheelUsed then
                    edtAzimuthMouseUp(nil,mbMiddle,[ssCtrl],0,0);
end;

procedure TfrmRotControl.edtAzimuthMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   Key : word = VK_Return;
begin
  if Button=mbLeft then
   Begin
    CaretMousePos:=edtAzimuth.CaretPos.X-1;
    if  CaretMousePos<0 then  CaretMousePos:=0;
    edtAzimuth.SelStart:=CaretMousePos;
    edtAzimuth.SelLength:=1;
    Exit;
   end;
 if Button=mbMiddle then
    edtAzimuthKeyUp(nil,Key,Shift);
end;

procedure TfrmRotControl.edtAzimuthMouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
var
  s : String;
  c : char;
  f : integer;
begin
    MouseWheelUsed:=true;
    s:=edtAzimuth.Text;
     c:= s[CaretMousePos+1];
     if c='.' then Exit;

     if WheelDelta < 0 then
        begin
         c:=Pred(c);
         if c<'0' then  c:='9'
        end
      else
        begin
         c:=Succ(c);
         if c>'9' then  c:='0'
        end;

     s[CaretMousePos+1]:=c;

     if (length(s)=3) then
      begin
      if  (s[1] > '3') then s[1]:='0';
      if ((s[1] = '3') and (s[2]>'6')) then s[2]:='6';
      if ((s[1] = '3') and (s[2]='6')) then s[3]:='0';
      end;
     edtAzimuth.Text :=s;
     edtAzimuth.SelStart:=CaretMousePos;
     edtAzimuth.SelLength:=1;
end;

procedure TfrmRotControl.tmrStopRotTimer(Sender: TObject);
begin
  btnStopClick(nil);
end;
procedure TfrmRotControl.UpdateAZdisp(Az,AzMin,AzMax:Double;UseState:boolean);
Begin
  lblAzMin.Caption:=FloatToStrF(AzMin, fffixed, 3, 0);
  lblAzMax.Caption:=FloatToStrF(AzMax, fffixed, 3, 0);
  pbAz.Min:=round(AzMin);
  pbAz.Max:=round(AzMax);
  pbAz.Smooth:=True;
  pbAz.Step:=1;
  pbAz.Enabled:=True;
  if (UseState and (AzMin<0 ) and (az>180)) then az := az-360;

  pbAz.Position:=round(Az);
end;

function TfrmRotControl.InicializeRot : Boolean;
var
  n      : String = '';
  id     : Integer = 0;
  port   : Integer;
  poll   : Integer;
begin
  if Assigned(rotor) then
  begin
    FreeAndNil(rotor);
  end;
  Application.ProcessMessages;
  Sleep(500);

  tmrRotor.Enabled := False;

  if rbRotor1.Checked then
    n := '1'
  else
    n := '2';

  rotor := TRotControl.Create;
  if dmData.DebugLevel>0 then
    rotor.DebugMode := True;
  if not TryStrToInt(cqrini.ReadString('ROT'+n,'model',''),id) then
    rotor.RotId := 1
  else
    rotor.RotId := id;

  //broken configuration caused crash because RotCtldPort was empty
  //probably late to change it to Integer, I have no idea if the current
  //setting would be converted automatically or user has to do it again :(


  //OH1KH 2022-12-09: cqrini.ReadInteger and  cqrini.ReadString both can be used!
  //Works same way as database ReadAsString or ReadAsInteger; Source is same but resulting read is
  //either String or Integer how programmer wants.
  //cqrini.Write does not make difference in config file if variable is saved as String or Integer
  //both results look same in .cfg file.

  port:= cqrini.ReadInteger('ROT'+n, 'RotCtldPort', 4533);
  if ((port>65534) or (port<1024)) then port := 4533;  //limit values

  poll:=cqrini.ReadInteger('ROT'+n, 'poll', 500);
  if ((poll>60000) or (poll<10)) then  poll := 500;  //limit values

  rotor.RotCtldPath := cqrini.ReadString('ROT','RotCtldPath','/usr/bin/rotctld');
  rotor.RotCtldArgs := dmUtils.GetRotorRotCtldCommandLine(StrToInt(n));
  rotor.RunRotCtld  := cqrini.ReadBool('ROT'+n,'RunRotCtld',False);
  rotor.RotDevice   := cqrini.ReadString('ROT'+n,'device','');
  rotor.RotCtldPort := port;
  rotor.RotCtldHost := cqrini.ReadString('ROT'+n,'host','localhost');
  rotor.RotPoll     := poll;

  tmrRotor.Interval := rotor.RotPoll;
  tmrRotor.Enabled  := True;
  Result := True;
  if not rotor.Connected then
  begin
    FreeAndNil(rotor)
  end
end;

procedure TfrmRotControl.SynROT;
var
  Az          :Double;
  mylat,mylon :currency;
  exlat,exlon :extended;
  dist        :longint;
begin
  exlon:=0;
  exlat:=0;
  dist :=1000;
  if Assigned(rotor) then
   begin
    Az := rotor.GetAzimut;
    if Az<0 then Az:=360-Az;
    if frmGrayline.Showing then
       Begin
        if (Trunc(Az)<>BeamDir) then
          begin
           if frmGrayline.pumShowBeamPath.Checked then
            Begin
              dist :=cqrini.ReadInteger('Program', 'GraylineGBeamLineLength',1500); //in kilometers
              dmutils.CoordinateFromLocator(frmNewQSO.CurrentMyLoc,mylat,mylon);
              frmGrayline.CalculateLatLonOfNewPoint(mylon,mylat,dist,Trunc(Az),exlon,exlat);
              frmGrayline.PlotGreatCircleArcLine(mylon,mylat,exlon,exlat,2);
              Beamdir:=Trunc(Az);
            end;
           dmUtils.ModifyXplanetBeam(mylat,mylon,exlat,exlon);
          end;
       end;
   end
  else
  Az := 0;
  lblAzimuth.Caption := FormatFloat(empty_azimuth+';;',Az)
end;

end.

