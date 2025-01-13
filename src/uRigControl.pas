unit uRigControl;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Process, ExtCtrls, lNetComponents, lnet, Forms, strutils;

type TRigMode =  record
    mode : String[10];
    pass : integer;   //this can not be word as rigctld uses "-1"="keep as is" IntToStr gives 65535 for word with -1
    raw  : String[10];
end;

type TVFO = (VFOA,VFOB);


type
  TExplodeArray = Array of String;

type TRigControl = class
    RigctldConnect : TLTCPComponent;
    RigctldCmd     : TLTCPComponent;
    rigProcess     : TProcess;
    tmrRigPoll     : TTimer;
  private
    fRigCtldPath   : String;
    fRigCtldArgs   : String;
    fRunRigCtld    : Boolean;
    fMode          : TRigMode;
    fFreq          : Double;
    fSFreq         : Double;
    fRigPoll       : Word;
    fRigCtldPort   : Word;
    fLastError     : String;
    fRigId         : Word;
    fRigDevice     : String;
    fDebugMode     : Boolean;
    fRigCtldHost   : String;
    fVFO           : TVFO;
    RigCommand     : TStringList;
    fRigSendCWR    : Boolean;
    fRigChkVfo     : Boolean;
    fRXOffset      : Double;
    fTXOffset      : Double;
    fMorse         : boolean;
    fPower         : boolean;
    fPowerON	    : boolean;
    fGetVfo         : boolean;
    fCompoundPoll   : Boolean;
    fVoice          : Boolean;
    fIsNewHamlib    : Boolean;
    fGetSplitTX     : Boolean;
    fRigSplitActive : Boolean;
    fPollTimeout    : integer;
    fPollCount      : integer;
    fPwrPcnt        : String;   //not actually %, but value 0.0 .. 1.0
    fPwrmW          : String;
    fGetRFPower     : boolean;
    fSetRFPower     : boolean;
    fSetFunc        : boolean; //if can set/get func then test "U currVFO ?" supported functions "fSupFuncs"
    fGetFunc        : boolean;
    fSupFuncs       : String;
    fResponseTimeout : Boolean;
    AllowCommand    : integer; //for command priority
    ErrorRigctldConnect : Boolean;
    ConnectionDone  : Boolean;
    PowerOffIssued  : Boolean;

    RigCmdChannelBusy : Boolean;
    RigCmdChannelMsg  : String;


    function  RigConnected   : Boolean;
    function  StartRigctld   : Boolean;
    function  Explode(const cSeparator, vString: String): TExplodeArray;
    function  SendCmd(cmd:string):boolean;
    function  SendPoll(msg:string):boolean;

    //Connect is for rig initate and fmv polling
    procedure OnReceivedRigctldConnect(aSocket: TLSocket);
    procedure OnConnectRigctldConnect(aSocket: TLSocket);
    procedure OnErrorRigctldConnect(const msg: string; aSocket: TLSocket);
    procedure OnRigPollTimer(Sender: TObject);

    //Command is for other rig commands
    procedure OnReceivedRigctldCmd(aSocket: TLSocket);
    procedure OnConnectRigctldCmd(aSocket: TLSocket);
    procedure OnErrorRigctldCmd(const msg: string; aSocket: TLSocket);

    procedure HamlibErrors(e:string);

public

    ParmVfoChkd : Boolean;
    ParmHasVfo  : integer;
    VfoStr      : String;
    InitDone    : Boolean;

    constructor Create;
    destructor  Destroy; override;

    property DebugMode   : Boolean read fDebugMode write fDebugMode;

    property RigCtldPath : String  read fRigCtldPath write fRigCtldPath;
    //path to rigctld binary
    property RigCtldArgs : String  read fRigCtldArgs write fRigCtldArgs;
    //rigctld command line arguments
    property RunRigCtld  : Boolean read fRunRigCtld  write fRunRigCtld;
    //run rigctld command before connection
    property RigId       : Word    read fRigId       write fRigId;
    //hamlib rig id
    property RigDevice   : String  read fRigDevice   write fRigDevice;
    //port where is rig connected
    property RigCtldPort : Word    read fRigCtldPort write fRigCtldPort;
    // port where rigctld is listening to connecions, default 4532
    property RigCtldHost : String  read fRigCtldHost write fRigCtldHost;
    //host where is rigctld running
    property Connected   : Boolean read RigConnected;
    //connect rigctld
    property RigPoll     : Word    read fRigPoll     write fRigPoll;
    //poll rate in milliseconds
    property RigSendCWR  : Boolean read fRigSendCWR    write fRigSendCWR;
    //send CWR instead of CW
    property RigChkVfo  : Boolean read fRigChkVfo    write fRigChkVfo;
    //test if rigctld "--vfo" start parameter is used
    property Morse      : Boolean read fMorse;
    //can rig send CW
    property Voice      : Boolean read fVoice;
    //can rig launch voice memories
    property IsNewHamlib: Boolean read fIsNewHamlib;
    //Is Hamlib version date higer than 2023-06-01
    //not used internally, but can give info out
    property Power      : Boolean read fPower;
    //can rig switch power
    property PowerON      : Boolean write fPowerON;
    //may rig switch power on at start
    property CanGetVfo  : Boolean read fGetVfo;
    //can rig show vfo (many Icoms can not)
    property LastError   : String  read fLastError;
    //last error during operation

    //RX offset for transvertor in MHz
    property RXOffset : Double read fRXOffset write fRXOffset;
    //TX offset for transvertor in MHz
    property TXOffset : Double read fTXOffset write fTXOffset;
    //TX freq from split vfo
    property GetSplitTX : Boolean read fGetSplitTX write  fGetSplitTX;
    property RigSplitActive : Boolean read fRigSplitActive;

    property GetRFPower: boolean read fGetRFPower;
    property SetRFPower: boolean read fSetRFPower;
    property SetFunc   : boolean read fSetFunc;
    property GetFunc   : boolean read fGetFunc;
    property SupFuncs  : String read fSupFuncs;

    property PwrPcnt :  String read fPwrPcnt write fPwrPcnt;
    property PwrmW   :  String read fPwrmW   write fPwrmW;

    property ResponseTimeout : Boolean read fResponseTimeout;

    //Char to use between compound commands. Default is space, can be also LineEnding that breaks compound
    property CompoundPoll : Boolean read fCompoundPoll  write  fCompoundPoll;
    property PollTimeout  : integer read fPollTimeout write fPolltimeout; //if ever needed to read or change from main program

    function  GetCurrVFO  : TVFO;
    function  GetModePass : TRigMode;
    function  GetPassOnly : word;
    function  GetModeOnly : String;
    function  GetFreqHz   : Double;
    function  GetFreqKHz  : Double;
    function  GetFreqMHz  : Double;
    function  GetSplitTXFreqMHz  : Double;
    function  GetModePass(vfo : TVFO) : TRigMode;  overload;
    function  GetModeOnly(vfo : TVFO) : String; overload;
    function  GetFreqHz(vfo : TVFO)   : Double; overload;
    function  GetFreqKHz(vfo : TVFO)  : Double; overload;
    function  GetFreqMHz(vfo : TVFO)  : Double; overload;
    function  GetRawMode : String;
    function  GetPowerPercent: integer;
    function  GetPowermW : integer;

    procedure SetCurrVFO(vfo : TVFO);
    procedure SetModePass(mode : TRigMode);
    procedure SetFreqKHz(freq : Double);
    procedure SetSplit(up:integer);
    procedure DisableSplit;  //this is disable XIT
    procedure ClearXit;
    procedure ClearRit;
    procedure DisableRit;
    procedure Restart;
    procedure PwrOn;
    procedure PwrOff;
    procedure PwrStBy;
    procedure PttOn;
    procedure PttOff;
    procedure SendVoice(VMem:String);
    procedure StopVoice;
    procedure UsrCmd(cmd:String);
    procedure SetPowerPercent(p:integer);
    procedure SetTuner;
    procedure ReSetTuner;
end;

implementation

constructor TRigControl.Create;
begin
  RigCommand           := TStringList.Create;
  RigCommand.Sorted    :=False;
  fDebugMode           := False;
  if DebugMode then Writeln('In create');
  fRigCtldHost         := 'localhost';
  fRigCtldPort         := 4532;
  fRigPoll             := 500;   //Check relationship to fPollTimeout
  fRunRigCtld          := True;
  RigctldConnect       := TLTCPComponent.Create(nil);
  RigctldCmd           := TLTCPComponent.Create(nil);
  rigProcess           := TProcess.Create(nil);
  tmrRigPoll           := TTimer.Create(nil);
  tmrRigPoll.Enabled   := False;
  VfoStr               := ''; //defaults to non-"--vfo" (legacy) mode
  fPowerON             := true;  //we do this via rigctld startup parameter autopower_on
  fGetVfo              := true;   //defaut these true
  fMorse               := true;
  fVoice               := false;
  fIsNewHamlib         := false;
  fGetSplitTX          := false;  //poll rig polls also split TX vfo
  PowerOffIssued       := false;
  fCompoundPoll        := True;
  fPollTimeout         := 20;  //max count of false responses when polled. Set_power ON is critical. Must be big enough to allow rig wake up.
  fPollCount           := fPollTimeout;
  fRigSplitActive      := False;
  fGetRFPower          := false;
  fSetRFPower          := false;
  fGetFunc             := false;
  fSetFunc             := false;
  fSupFuncs            := '';
  if DebugMode then Writeln('All objects created');
  tmrRigPoll.OnTimer       := @OnRigPollTimer;
  RigctldConnect.OnReceive := @OnReceivedRigctldConnect;
  RigctldConnect.OnConnect := @OnConnectRigctldConnect;
  RigctldConnect.OnError   := @OnErrorRigctldConnect;
  RigctldCmd.OnReceive     := @OnReceivedRigctldCmd;
  RigctldCmd.OnConnect     := @OnConnectRigctldCmd;
  RigctldCmd.OnError       := @OnErrorRigctldCmd;
end;

function TRigControl.StartRigctld : Boolean;
var
   index     : integer;
   paramList : TStringList;
begin

  if fDebugMode then Writeln('Starting RigCtld ...');

  rigProcess.Executable := fRigCtldPath;
  index:=0;
  paramList := TStringList.Create;
  paramList.Delimiter := ' ';
  if pos('AUTO_POWER',UpperCase(RigCtldArgs))=0 then
   if (RigId>10) then  //only true rigs can do auto_power_on
    begin
    if fPowerON then RigCtldArgs:= RigCtldArgs+' -C auto_power_on=1';
          //2023-08-02 auto_power on is not any more default "1" and it should stay so (by W9MDB)
          //so we need just set it "1" if user wants, otherwise no parameter added. This should help old Hamlibs
          //that claim auto_power is wrong parameter and refuse to start.
          //If there are Hamlibs that defaut to "1" user must set "Extra command line parameters" as
          //-C auto_power_on=0
      //else RigCtldArgs:= RigCtldArgs+' -C auto_power_on=0';
    end;
  paramList.DelimitedText := RigCtldArgs;
  rigProcess.Parameters.Clear;
  while index < paramList.Count do
  begin
    rigProcess.Parameters.Add(paramList[index]);
    inc(index);
  end;
  paramList.Free;
  if fDebugMode then Writeln('rigProcess.Executable: ',rigProcess.Executable,LineEnding,'Parameters:',LineEnding,rigProcess.Parameters.Text);

  try
    rigProcess.Execute;
    sleep(1500);
    if not rigProcess.Active then
    begin
      Result := False;
      exit
    end
  except
    on E : Exception do
    begin
      if fDebugMode then
        Writeln('Starting rigctld E: ',E.Message);
      fLastError := E.Message;
      Result     := False;
      exit
    end
  end;
  Result := True
end;

function TRigControl.RigConnected  : Boolean;
const
  ERR_MSG = 'Could not connect to rigctld';
var
 RetryCount    : integer;
 Connection2Done: boolean;

begin
  if fDebugMode then
  begin
    Writeln('');
    Writeln('Settings:');
    Writeln('-----------------------------------------------------');
    Writeln('RigCtldPath:',RigCtldPath);
    Writeln('RigCtldArgs:',RigCtldArgs);
    Writeln('RunRigCtld: ',RunRigCtld);
    Writeln('RigDevice:  ',RigDevice);
    Writeln('RigCtldPort:',RigCtldPort);
    Writeln('RigCtldHost:',RigCtldHost);
    Writeln('RigPoll:    ',RigPoll);
    Writeln('RigSendCWR: ',RigSendCWR);
    Writeln('RigChkVfo   ',RigChkVfo);
    Writeln('RigId:      ',RigId);
    Writeln('')
  end;

  if fRunRigCtld then
   begin
    if not StartRigctld then
      begin
        if fDebugMode then Writeln('rigctld failed to start!');
        Result := False;
        exit
      end
     else
      if fDebugMode then Writeln('rigctld started!');
   end
  else
    if fDebugMode then Writeln('Not started rigctld process. (Run is set FALSE)');


  RigctldConnect.Host := fRigCtldHost;
  RigctldConnect.Port := fRigCtldPort;
  RetryCount          := 1;
  ErrorRigctldConnect := False;
  ConnectionDone      := False;
  InitDone            :=false;
  fResponseTimeout    :=false;

  if RigctldConnect.Connect(fRigCtldHost,fRigCtldPort) then//this does not work as connection indicator, is always true!!
   Begin
     repeat
         begin
            if fDebugMode then
                          Writeln('Waiting for rigctld Poll ',RetryCount,' @ ',fRigCtldHost,':',fRigCtldPort);
            if  ErrorRigctldConnect then
                Begin
                  ErrorRigctldConnect := False;
                  RigctldConnect.Connect(fRigCtldHost,fRigCtldPort);
                end;
            inc(RetryCount);
            sleep(1000);
            Application.ProcessMessages;
          end;
     until (ConnectionDone or (Retrycount > 10)) ;

     if ConnectionDone then
      Begin
       if fDebugMode then
                     Writeln('Connected to rigctld Poll (RigConnected)');
       result := True
      end
    else
      begin
       if fDebugMode then
                     Writeln('RETRY ERROR: *NOT* connected to rigctld Poll @ ',fRigCtldHost,':',fRigCtldPort);
       fLastError := ERR_MSG;
       Result     := False
      end;

   //connection 2
   if ConnectionDone then
    Begin
      ConnectionDone:=false;
      RetryCount    := 1;
      if RigctldCmd.Connect(fRigCtldHost,fRigCtldPort) then//this does not work as connection indicator, is always true!!
         Begin
           repeat
           begin
              if fDebugMode then
                            Writeln('Waiting for rigctld Cmd ',RetryCount,' @ ',fRigCtldHost,':',fRigCtldPort);
              if  ErrorRigctldConnect then
                  Begin
                    ErrorRigctldConnect := False;
                    RigctldCmd.Connect(fRigCtldHost,fRigCtldPort);
                  end;
              inc(RetryCount);
              sleep(1000);
              Application.ProcessMessages;
            end;
           until (ConnectionDone or (Retrycount > 10)) ;
          end;
     end;

    if ConnectionDone then
      Begin
       if fDebugMode then
                     Writeln('Connected to rigctld Cmd! (RigConnected)');
       result := True
      end
    else
      begin
       if fDebugMode then
                     Writeln('RETRY ERROR: *NOT* connected to rigctld Cmd @ ',fRigCtldHost,':',fRigCtldPort);
       fLastError := ERR_MSG;
       Result     := False
      end;
    end
  else
   begin
    if fDebugMode then
                  Writeln('SETTINGS ERROR: *NOT* connected to rigctld @ ',fRigCtldHost,':',fRigCtldPort);
    fLastError := ERR_MSG;
    Result     := False
   end;

end;


procedure TRigControl.SetCurrVFO(vfo : TVFO);
begin
  case vfo of
    VFOA : SendCmd('V VFOA');
    VFOB : SendCmd('V VFOB');
  end; //case
end;

procedure TRigControl.SetModePass(mode : TRigMode);
begin
  if (mode.mode='CW') and fRigSendCWR then
    mode.mode := 'CWR';
  SendCmd('+\set_mode'+VfoStr+' '+mode.mode+' '+IntToStr(mode.pass));
end;

procedure TRigControl.SetFreqKHz(freq : Double);
begin
  SendCmd('+\set_freq'+VfoStr+' '+FloatToStr(freq*1000-TXOffset*1000000));
end;

procedure TRigControl.SetTuner;
begin
  if fSetFunc and (Pos('TUNER', fSupFuncs)>0) then
    SendCmd('+\set_func'+VfoStr+' TUNER 1');
end;

procedure TRigControl.ReSetTuner;
begin
  if fSetFunc and (Pos('TUNER', fSupFuncs)>0) then
    SendCmd('+\set_func'+VfoStr+' TUNER 0');
end;
procedure TRigControl.ClearRit;
begin
  SendCmd('+\set_rit'+VfoStr+' 0');
end;
procedure TRigControl.DisableRit;
Begin
  SendCmd('+\set_func'+VfoStr+' RIT 0');
end;
procedure TRigControl.SetSplit(up:integer);
Begin
  if not SendCmd('+\set_xit'+VfoStr+' '+IntToStr(up)) then
                                                      exit;
  if pos('RPRT 0', RigCmdChannelMsg)>0 then
    SendCmd( '+\set_func'+VfoStr+' XIT 1');
end;
procedure TRigControl.ClearXit;
begin
 SendCmd('+\set_xit'+VfoStr+' 0');
end;
procedure TRigControl.DisableSplit;
Begin
 SendCmd('+\set_func'+VfoStr+' XIT 0');
end;
procedure TRigControl.PttOn;
begin
  SendCmd('+\set_ptt'+VfoStr+' 1');
end;
procedure TRigControl.PttOff;
begin
 SendCmd('+\set_ptt'+VfoStr+' 0');
end;
procedure TRigControl.SendVoice(Vmem:String);
begin
  SendCmd('+\send_voice_mem '+Vmem);
end;
procedure TRigControl.StopVoice;
begin
  SendCmd('+\stop_voice_mem');
end;
procedure TRigControl.PwrOn;
begin
  AllowCommand:=8; //high prority  passes -1 state
end;
procedure TRigControl.PwrOff;
begin
  PowerOffIssued:=true;
  RigCommand.Add('+\set_powerstat 0');
end;
procedure TRigControl.PwrStBy;
begin
   PowerOffIssued:=true;
   RigCommand.Add('+\set_powerstat 2');
end;
procedure TRigControl.UsrCmd(cmd:String);
begin
  if (cmd<>'') then SendCmd(cmd);
end;

procedure TRigControl.SetPowerPercent(p:integer);
begin
  if not fSetRFPower then exit;
  SendCmd('+\set_level'+VfoStr+' RFPOWER '+FloatToStrF(p/100,ffFixed,3,2));
end;

function TRigControl.GetCurrVFO  : TVFO;
begin
  result := fVFO
end;

function TRigControl.GetModePass : TRigMode;
begin
  result := fMode
end;
function TRigControl.GetRawMode : String;
begin
  Result := fMode.raw
end;
function TRigControl.GetModeOnly : String;
begin
  result := fMode.mode
end;
function TRigControl.GetPassOnly : word;
begin
  result := fMode.pass
end;

function TRigControl.GetFreqHz : Double;
begin
  result := fFreq + fRXOffset*1000000;
end;

function TRigControl.GetFreqKHz : Double;
begin
  result := (fFreq + fRXOffset*1000000) / 1000
end;

function TRigControl.GetFreqMHz : Double;
begin
  result := (fFreq + fRXOffset*1000000) / 1000000
end;

function TRigControl.GetSplitTXFreqMHz : Double;
begin
  result := fSFreq / 1000000
end;

function  TRigControl.GetPowerPercent: integer;
 var
    p: Double;
begin
  if not fGetRFPower then exit;
  fPwrPcnt:= '';
  Result:=-1; //error or not set
  if not SendCmd('+\get_level'+VfoStr+' RFPOWER') then
                                                  exit;
  if pos('RPRT 0', RigCmdChannelMsg)>0 then
   begin
    fPwrPcnt:= ExtractWord(2,RigCmdChannelMsg,['|']);
    try
      if TryStrToFloat(fPwrPcnt,p) then
                                   Result:= Round(100* p);
    finally
    end;
   end;
end;
function  TRigControl.GetPowermW : integer;
var
 f:string;
 r:integer;
begin
    if not fGetRFPower then exit;
    fPwrmW:='';//error or not set
    Result:=-1;
    f:=FloatToStr(fFreq);
    GetPowerPercent;
    if GetPowerPercent >-1 then
       Begin
        if not SendCmd('+\power2mW '+fPwrPcnt+' '+f+' '+fMode.mode) then
                                                                    exit;
        if pos('RPRT 0', RigCmdChannelMsg)>0 then
         Begin
         f:= ExtractWord(2,RigCmdChannelMsg,['|']);
         f:= ExtractWord(3,f,[' ']);
         if TryStrToInt(f,r) then
          Result:=r;
         end;
       end;
end;

function TRigControl.GetModePass(vfo : TVFO) : TRigMode;
var
  old_vfo : TVFO;
begin
  if fVFO <> vfo then
  begin
    old_vfo := fVFO;
    SetCurrVFO(vfo);
    Sleep(fRigPoll*2);
    result := fMode;
    SetCurrVFO(old_vfo)
  end;
  result := fMode
end;

function TRigControl.GetModeOnly(vfo : TVFO) : String;
var
  old_vfo : TVFO;
begin
  if fVFO <> vfo then
  begin
    old_vfo := fVFO;
    SetCurrVFO(vfo);
    Sleep(fRigPoll*2);
    result := fMode.mode;
    SetCurrVFO(old_vfo)
  end;
  result := fMode.mode
end;

function TRigControl.GetFreqHz(vfo : TVFO)   : Double;
var
  old_vfo : TVFO;
begin
  if fVFO <> vfo then
  begin
    old_vfo := fVFO;
    SetCurrVFO(vfo);
    Sleep(fRigPoll*2);
    result := fFreq;
    SetCurrVFO(old_vfo)
  end;
  result := fFreq
end;

function TRigControl.GetFreqKHz(vfo : TVFO)  : Double;
var
  old_vfo : TVFO;
begin
  if fVFO <> vfo then
  begin
    old_vfo := fVFO;
    SetCurrVFO(vfo);
    Sleep(fRigPoll*2);
    result := fFreq/1000;
    SetCurrVFO(old_vfo)
  end;
  result := fFreq
end;

function TRigControl.GetFreqMHz(vfo : TVFO)  : Double;
var
  old_vfo : TVFO;
begin
  if fVFO <> vfo then
  begin
    old_vfo := fVFO;
    SetCurrVFO(vfo);
    Sleep(fRigPoll*2);
    result := fFreq/1000000;
    SetCurrVFO(old_vfo)
  end;
  result := fFreq
end;

procedure TRigControl.OnReceivedRigctldConnect(aSocket: TLSocket);
var
  msg : String;
  a,b : TExplodeArray;
  i   : Integer;
  f   : Double;
  Hit : boolean;
  tmp : string;
  MaxArg: integer;

begin
  msg:='';
  while (( aSocket.GetMessage(msg) > 0 ) and (not ResponseTimeout)) do
  begin
    msg := StringReplace(upcase(trim(msg)),#$09,' ',[rfReplaceAll]); //note the char case upper for now on! Remove TABs
    if DebugMode then
         Writeln('Msg from rig:',StringReplace(msg,LineEnding,'|',[rfReplaceAll]));

     a := Explode(LineEnding,msg);
    MaxArg:=Length(a)-1;

    for i:=0 to MaxArg do     //this handles received message line by line
    begin
      Hit:=false;
      if DebugMode then
         Writeln('a['+IntToStr(i)+']:',a[i]);
      if a[i]='' then Continue;

      //we send all commands with '+' prefix that makes receiving sort lot easier
      b:= Explode(' ', a[i]);


      if (b[0]='FREQUENCY:')then
       Begin
         if TryStrToFloat(b[1],f) then
           Begin
             fFReq := f;
           end
          else
           fFReq := 0;
          Hit:=true;
          AllowCommand:=1; //check pending commands
       end;

      if ((b[0]='TX') and (b[1]='FREQUENCY:') )then    //get split TX freq
       Begin
         if TryStrToFloat(b[2],f) then
           Begin
             fSFReq := f;
           end
          else
           fSFReq := 0;
          Hit:=true;
          AllowCommand:=1; //check pending commands
       end;

       if (b[0]='SPLIT:')then
       Begin
         fRigSplitActive:= (b[1] = '1');
       end;

       if ( (b[0]='TX') and (b[1]='MODE:') ) then   //WFview false rigctld emulating says "TX MODE:"
        Begin
          b[0]:=b[1];
          b[1]:=b[2];
        end;

      if (b[0]='MODE:') then
       Begin
         fMode.raw  := b[1];
         fMode.mode :=  fMode.raw;
         if (fMode.mode = 'USB') or (fMode.mode = 'LSB') then
           fMode.mode := 'SSB';
         if fMode.mode = 'CWR' then
           fMode.mode := 'CW';
         Hit:=true;
         AllowCommand:=1;
        end;

      //FT-920 returned VFO as MEM
      //Some rigs report VFO as Main,MainA,MainB or Sub,SubA,SubB
      //Hamlib dummy has also "None" could it be in some real rigs too?
      if (b[0]='VFO:') then
       Begin
         b:= Explode(' ', a[i]);
         case b[1] of
           'VFOA',
           'MAIN',
           'MAINA',
           'SUBA'    :fVFO := VFOA;

           'VFOB',
           'SUB',
           'MAINB',
           'SUBB'    :fVFO := VFOB;
          else
            fVFO := VFOA;
         end;
         Hit:=true;
         AllowCommand:=1;
        end;


       if b[0]='CHKVFO:' then //Hamlib 4.3
        Begin
         ParmVfoChkd:=true;
         if b[1]='1' then
                        ParmHasVfo := 1;
         if DebugMode then Writeln('"--vfo" checked:',ParmHasVfo);
         if ParmHasVfo > 0 then VfoStr:=' currVFO';  //note set leading one space to string!
         Hit:=true;
         AllowCommand:=9; //next dump caps
        end;

       if b[0]='CHKVFO' then //Hamlib 3.1
        Begin
         ParmVfoChkd:=true;
         if b[1]='1' then
                        ParmHasVfo := 2;
         if DebugMode then Writeln('"--vfo" checked:',ParmHasVfo);
         if ParmHasVfo > 0 then VfoStr:=' currVFO';  //note set leading one space to string!
         Hit:=true;
         AllowCommand:=9; //next dump caps
        end;

      //these come from\dump_caps
       if pos('HAMLIB VERSION:',a[i])>0 then
             Begin                   //Old hamlib does not have this line, new has.
               fIsNewHamlib:= true; //this is enough now to now it exist. Later version number and date can be used if needed
             end;

       if pos('CAN SET POWER STAT:',a[i])>0 then
       Begin
         fPower:= b[4]='Y';
       end;

      if pos('CAN GET VFO:',a[i])>0 then
       Begin
         fGetVfo:= b[3]='Y';
       end;

      if pos('CAN SET FUNC:',a[i])>0 then
       Begin
         fSetFunc:= b[3]='Y';
       end;
      if pos('CAN GET FUNC:',a[i])>0 then
       Begin
         fGetFunc:= b[3]='Y';
       end;

      if pos('CAN SEND MORSE:',a[i])>0 then
       Begin
         fMorse:= b[3]='Y';
       end;

       if pos('CAN SEND VOICE:',a[i])>0 then
       Begin
         fVoice:= b[3]='Y';
       end;
       if pos('CAN GET POWER2MW:',a[i])>0 then
       begin
          fGetRFPower:= b[3]='Y';
       end;
       if pos('CAN GET MW2POWER:',a[i])>0 then
       begin
         fSetRFPower:= b[3]='Y';


         RigCommand.Clear;
         Hit:=true;
         if ((fRigId<10) and fPowerON and fPower) then
               AllowCommand:=8 // if rigctld is remote it can not make auto_power_on as startup parameter
                               // then we should send set_powerstat 1 if power up is asked and rig can do it
           else
               AllowCommand:=1; //check pending commands (should not be any)
         if DebugMode then
                   Begin
                      Writeln(LineEnding,'This is New Hamlib: ',fIsNewHamlib);
                      Writeln('Cqrlog can switch power: ',fPower);
                      Writeln('Cqrlog can get VFO: ',fGetVfo);
                      Writeln('Cqrlog can get func: ',fGetFunc);
                      Writeln('Cqrlog can set func: ',fSetFunc);
                      Writeln('Cqrlog can send Morse: ',fMorse);
                      Writeln('Cqrlog can launch voice memories: ',fVoice);
                      Writeln('Cqrlog can get power2mW: ',fGetRFPower);
                      Writeln('Cqrlog can set mW2power: ',fSetRFPower,LineEnding);
                   end;

         if fSetFunc then
                 RigCommand.Add('+\set_func'+VfoStr+' ?'+LineEnding)
          else
            Begin
             sleep(1000);
             InitDone:=true;
            end;

         Break;  //break searching from \dump_caps reply
       end;
      //\dump_caps end

       if ((pos('RFPOWER',a[i])>0) and (i+2 <= MaxArg)) then //must check that array a[] has i+2 members
         if (pos('RPRT 0',a[i+2])>0) then
          Begin
           Hit:=true;
           fPwrPcnt:= a[i+1];
           tmp:=FloatToStr(fFreq);
           if fGetRFPower then
             RigCommand.Add('+\power2mW '+fPwrPcnt+' '+tmp+' '+fMode.mode+LineEnding);
          end;

       if ((pos('POWER MW:',a[i])>0) and (i+1 <= MaxArg)) then
        if(pos('RPRT 0',a[i+1])>0) then
         Begin
          Hit:=true;
          fPwrmW:=b[2];
         end;

       if ((pos('SET_FUNC',a[i])>0) and (pos('?',a[i])>0) and  (i+2 <= MaxArg)) then
        if (pos('RPRT 0',a[i+2])>0) then
          Begin
            Hit:=true;
            fSupFuncs:=a[i+1];
            InitDone:=true;
            AllowCommand:=1;
            Break;
          end;

       if pos('SET_POWERSTAT:',a[i])>0 then
       Begin
         Hit:=true;
         if pos('1',a[i])>0 then //line may have 'STAT: 1' or 'STAT: CURRVFO 1'
          Begin
            if DebugMode then Writeln('Power on, start polling');
            AllowCommand:=92; //check pending commands via delay Assume rig needs time to start
            PowerOffIssued:=false;
          end
         else
          Begin
            if DebugMode then Writeln('Power off, stop poll decode (-2)');
            AllowCommand:=-2; //there is no timeout for this
            Exit;
          end;
       end;


       if (b[0]='RPRT') then
       Begin
         //if none of above hits what to expect we accept just report received to be the one
         if not Hit then AllowCommand:=1;
           HamlibErrors(b[1]);
       end;

   end;  //line by line loop
  end; //while msg

end;
procedure TRigControl.OnRigPollTimer(Sender: TObject);
var
  cmd     : String;
  i       : Integer;
//-----------------------------------------------------------
procedure DoRigPoll;
var
   f:integer;
   s:array[1..5] of string=('','','','','');

begin
  if   ((not RigctldConnect.Connected)
         or ResponseTimeout )
                       then exit;

 if  ParmHasVfo=2 then
   begin
     if fGetVfo then
        begin
          s[1]:='+f'+VfoStr;
          s[2]:='+m'+VfoStr;
          s[3]:='+v'+VfoStr;
          if fGetSplitTX then
           Begin
             s[4]:='+i'+VfoStr;
             s[5]:='+s'+VfoStr;
           end;
          //cmd := '+f'+VfoStr+' +m'+VfoStr+' +v'+VfoStr+LineEnding //chk this with rigctld v3.1
        end
      else
        begin
          s[1]:='+f'+VfoStr;
          s[2]:='+m'+VfoStr;
          if fGetSplitTX then
           Begin
             s[3]:='+i'+VfoStr;
             s[4]:='+s'+VfoStr;
           end;
          //cmd := '+f'+VfoStr+' +m'+VfoStr+LineEnding //do not ask vfo if rig can't
        end

   end
  else
   begin
     if fGetVfo then
        begin
          s[1]:='+f'+VfoStr;
          s[2]:='+m'+VfoStr;
          s[3]:='+v';
          if fGetSplitTX then
           Begin
             s[4]:='+i'+VfoStr;
             s[5]:='+s'+VfoStr;
           end;
          //cmd := '+f'+VfoStr+' +m'+VfoStr+' +v'+LineEnding
        end
      else
      begin
          s[1]:='+f'+VfoStr;
          s[2]:='+m'+VfoStr;
          if fGetSplitTX then
           Begin
             s[3]:='+i'+VfoStr;
             s[4]:='+s'+VfoStr;
           end;
          //cmd := '+f'+VfoStr+' +m'+VfoStr+LineEnding //do not ask vfo if rig can't
        end
   end;


 if fCompoundPoll then
       Begin
        if DebugMode then
           Write(LineEnding+'Poll Sending:'+trim(s[1]+' '+s[2]+' '+s[3]+' '+s[4]+' '+s[5])+LineEnding);
        if not SendPoll(trim(s[1]+' '+s[2]+' '+s[3]+' '+s[4]+' '+s[5])+LineEnding) then exit;
       end
      else
        Begin
          for f:=1 to 5 do
            Begin
              if s[f]<>'' then
               Begin
                  if DebugMode then
                        Write(LineEnding+'Poll Sending:'+s[f]+LineEnding);
                  if not SendPoll(s[f]+LineEnding) then exit;
               end
              else
              break;
              sleep(2);
            end;
        end;

  if fGetRFPower then
    rigCommand.Add('+\get_level'+VfoStr+' RFPOWER'+LineEnding);

 AllowCommand:=-1; //waiting for reply
 fPollCount :=  fPollTimeout;
end;

//-----------------------------------------------------------
begin
 if DebugMode then
               Writeln('Polling - allowcommand:',AllowCommand);
 case AllowCommand of
     -2:  Exit;
     -1:  Begin
               dec(fPollCount);
               if fPollCount<1 then
                  Begin
                    if DebugMode then
                                Writeln('Rig/rigctld did not respond to command within timeout!');
                    tmrRigPoll.Enabled  := False;
                    fResponseTimeout := true;
                  end;
               Exit;   //no sending allowed
           end;

     //delay up to 10 timer rounds with this selecting one of numbers
     99:  AllowCommand:=98;
     98:  AllowCommand:=97;
     97:  AllowCommand:=96;
     96:  AllowCommand:=95;
     95:  AllowCommand:=94;
     94:  AllowCommand:=93;
     93:  AllowCommand:=92;
     92:  AllowCommand:=91;
     91:  AllowCommand:=1;

     //high priority commands
     10:  Begin
               cmd:='+\chk_vfo'+LineEnding;
               if DebugMode then
                     Write(LineEnding+'Sending: '+cmd);
               if not SendPoll(cmd) then exit;
               AllowCommand:=-1; //waiting for reply
               fPollCount :=  fPollTimeout;
          end;
      9:  Begin
               cmd:='+\dump_caps'+LineEnding;
                if DebugMode then
                     Write(LineEnding+'Sending: '+cmd);
               if not SendPoll(cmd) then exit;
               AllowCommand:=-1; //waiting for reply
               fPollCount :=  fPollTimeout;
          end;
      8:  Begin
               cmd:= '+\set_powerstat 1'+LineEnding;
               if DebugMode then
                     Write(LineEnding+'Sending: '+cmd);
               if not SendPoll(cmd) then exit;
               AllowCommand:=-1; //waiting for reply
               fPollCount :=  fPollTimeout;
          end;

      //lower priority commands queue handled here
      1:  Begin
            if (RigCommand.Text<>'') then
              begin
                if DebugMode then
                     write('Queue in:'+LineEnding,RigCommand.Text);
                 cmd := Trim(RigCommand.Strings[0])+LineEnding;
                  if DebugMode then
                          Write(LineEnding+'Queue Sending[0]:',cmd);
                 for i:=0 to RigCommand.Count-2 do
                    RigCommand.Exchange(i,i+1);
                  RigCommand.Delete(RigCommand.Count-1);
                  if DebugMode then
                     write('Queue out:'+LineEnding,RigCommand.Text);
                  if not SendPoll(cmd) then exit;
                  AllowCommand:=-1; //wait answer
                  fPollCount :=  fPollTimeout;
               end
              else
               DoRigPoll;
          end;

       //polling has lowest prority, do if there is nothing else to do
       0:  DoRigPoll;

 end;//case
end;
procedure TRigControl.OnConnectRigctldConnect(aSocket: TLSocket);
Begin
    if DebugMode then
                   Writeln('Connected to rigctld Poll (OnConnect)');

    ParmHasVfo:=0;   //default: "--vfo" is not used as start parameter
    AllowCommand:=10;  //start with chk_vfo
    RigCommand.Clear;
    tmrRigPoll.Interval := fRigPoll;
    tmrRigPoll.Enabled  := True;

    if RigChkVfo then
      Begin
        AllowCommand:=10;  //start with chkvfo
        ParmVfoChkd:=false;
      end
     else
      Begin
        AllowCommand:=9;  //otherwise start with dump caps
        ParmVfoChkd:=false;
      end;
    ConnectionDone:=true;
end;
procedure TRigControl.OnErrorRigctldConnect(const msg: string; aSocket: TLSocket);

begin
  ErrorRigctldConnect:= True;
  if DebugMode then
                   writeln(msg);
end;
function TRigControl.SendPoll(msg:string):boolean;
begin
  Result:=false;
  if   ((not RigctldConnect.Connected)
         or ResponseTimeout )
                       then exit;
  RigctldConnect.SendMessage(msg);
  Result:=true;
end;
procedure TRigControl.Restart;
var
  excode : Integer = 0;
begin
  tmrRigPoll.Enabled := False;
  sleep(fRigPoll);
  RigctldConnect.Disconnect(true);
  RigctldCmd.Disconnect(true);
  sleep(100);
  rigProcess.Terminate(excode);

  RigConnected
end;

function TRigControl.Explode(const cSeparator, vString: String): TExplodeArray;
var
  i: Integer;
  S: String;
begin
  S := vString;
  Result:=nil;
  SetLength(Result, 0);
  i := 0;
  while Pos(cSeparator, S) > 0 do begin
    SetLength(Result, Length(Result) +1);
    Result[i] := Copy(S, 1, Pos(cSeparator, S) -1);
    Inc(i);
    S := Copy(S, Pos(cSeparator, S) + Length(cSeparator), Length(S));
  end;
  SetLength(Result, Length(Result) +1);
  Result[i] := Copy(S, 1, Length(S))
end;

destructor TRigControl.Destroy;
var
  excode : Integer=0;
begin
  inherited;
  if DebugMode then Writeln('Destroy rigctld'+LineEnding+'1');
  if fRunRigCtld then
  begin
    if rigProcess.Running then
    begin
      if DebugMode then Writeln('1a');
      rigProcess.Terminate(excode)
    end
  end;
  if DebugMode then Writeln(2);
  tmrRigPoll.Enabled := False;
  sleep(fRigPoll);
  if DebugMode then Writeln(3);
  RigctldConnect.Disconnect();
  RigctldCmd.Disconnect();
  if DebugMode then Writeln(4);
  FreeAndNil(RigctldConnect);
  FreeAndNil(RigctldCmd);
  if DebugMode then Writeln(5);
  FreeAndNil(rigProcess);
  FreeAndNil(RigCommand);
  if DebugMode then Writeln('6'+LineEnding+'Done!')
end;
function TRigControl.SendCmd(cmd:string):boolean;
var
   t: integer;
Begin

 t:=0;
 Result:=false;
 if   ((not RigctldCmd.Connected)
         or ResponseTimeout
         or PowerOffIssued )
                       then exit;

 while (RigCmdChannelBusy and (t<2000)) do //waiting for free channel
  Begin
   Application.ProcessMessages;
   sleep(1);
   inc(t);
  end;

  if t>=2000 then
            Begin
              if DebugMode then
                Writeln('Send cmd: Failed to get free channel for: ',cmd);
              exit;
            end;
  RigCmdChannelBusy :=true;
  RigCmdChannelMsg:='';
  try
    RigctldCmd.SendMessage(cmd+LineEnding);
    if DebugMode then
     Writeln('Sent rigctld cmd: ',cmd,'(+LineEnding)');
  finally
  end;
  t:=0;
  repeat     //waiting for response from rigctld
  Begin
   Application.ProcessMessages;
   sleep(1);
   inc(t);
  end;
  until ( not RigCmdChannelBusy ) or (t>2000);
  if t>2000 then
           Begin
               if DebugMode then
                Writeln('Send cmd: Failed to get response to: ',cmd);
              exit;
            end;
  Result:=true;
end;
procedure TRigControl.OnReceivedRigctldCmd(aSocket: TLSocket);
var
  s:string;
Begin
  RigCmdChannelMsg := '';
  while (( aSocket.GetMessage(s) > 0 ) and (not ResponseTimeout)) do
    RigCmdChannelMsg := RigCmdChannelMsg+StringReplace(upcase(trim(s)),#$09,' ',[rfReplaceAll]); //note the char case upper for now on! Remove TABs

  RigCmdChannelMsg := StringReplace(RigCmdChannelMsg,LineEnding,'|',[rfReplaceAll]);
  if DebugMode then
     Begin
         Writeln('CmdMsg from rigctld:',RigCmdChannelMsg);
         s:= trim(copy(RigCmdChannelMsg,pos('RPRT', RigCmdChannelMsg)+5,4));
         Writeln(s);
         if ((pos('RPRT', RigCmdChannelMsg)>0) and (s<>'0')) then
            HamlibErrors(s);
     end;
  RigCmdChannelBusy :=false;
end;
procedure TRigControl.OnConnectRigctldCmd(aSocket: TLSocket);
Begin
 if DebugMode then
                   Writeln('Connected to rigctld Cmd! (OnConnect)');
  RigCmdChannelBusy :=false;
  RigCmdChannelMsg  :='';
  ConnectionDone    :=True;
end;
procedure TRigControl.OnErrorRigctldCmd(const msg: string; aSocket: TLSocket);
Begin
  ErrorRigctldConnect:= True;
  if DebugMode then
                   writeln(msg);
end;
procedure TRigControl.HamlibErrors(e:string);
Begin
  case e of
     '-1' : Writeln('Invalid parameter');
     '-2' : Writeln('Invalid configuration (serial,..)');
     '-3' : Writeln('Memory shortage');
     '-4' : Writeln('Function not implemented, but will be');
     '-5' : Writeln('Communication timed out');
     '-6' : Writeln('IO error, including open failed');
     '-7' : Writeln('Internal Hamlib error, huh!');
     '-8' : Writeln('Protocol error');
     '-9' : Writeln('Command rejected by the rig');
     '-10': Writeln('Command performed, but arg truncated');
     '-11': Writeln('Function not available');
     '-12': Writeln('VFO not targetable');
     '-13': Writeln('Error talking on the bus');
     '-14': Writeln('Collision on the bus');
     '-15': Writeln('NULL RIG handle or any invalid pointer parameter in get arg');
     '-16': Writeln('Invalid VFO');
     '-17': Writeln('Argument out of domain of func');
     '-18': Writeln('Function deprecated');
     '-19': Writeln('Security error password not provided or crypto failure');
     '-20': Writeln('Rig is not powered on');
  end;
end;


end.

