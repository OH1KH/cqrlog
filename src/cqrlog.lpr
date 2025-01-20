program cqrlog;

{$mode objfpc}{$H+}
uses
  cmem,cthreads,uScrollBars,
  Interfaces, // this includes the LCL widgetset
  Forms, sysutils, Classes, fMain, fPreferences, dUtils, fNewQSO, dialogs, process, FileUtil, StrUtils,
  fChangeLocator, fChangeOperator, dData, dDXCC, fMarkQSL, fDXCCStat, fSort,
  fFilter, fImportProgress, fImportTest,
  fSelectDXCC, fGrayline, fCallbook, fTRXControl,
  fFreq, fChangeFreq, fAdifImport, fSplash, fSearch, fQTHProfiles,
  fNewQTHProfile, fEnterFreq, fExportProgress, fNewDXCluster, fDXCluster,
  fDXClusterList, dDXCluster, fWorking, fSerialPort, fQSLMgr, fSendSpot,
  fQSODetails, fUpgrade, fWAZITUStat, fIOTAStat, fClubSettings, fLoadClub,
  fRefCall, fGraphStat, fBandMap, fBandMapWatch, fLongNote, fDatabaseUpdate,
  fExLabelPrint, fImportLoTWWeb, fLoTWExport, fGroupEdit, fDefaultFreq,
  fCustomStat, fKeyTexts, fCWType, fSplitSettings, MemDSLaz, SDFLaz,
  turbopoweripro, fShowStations, uMyIni, fPropagation, fSQLConsole,
  fCallAttachment, fEditDetails, fQSLViewer, fCWKeys, fSCP, fDBConnect, fNewLog,
  fRebuildMembStat, uVersion, fAbout, fChangelog, fBigSquareStat, feQSLDownload,
  feQSLUpload, fSOTAExport, fEDIExport, fNewQSODefValues, fQSLExpPref,
  fRotControl, dLogUpload, fLogUploadStatus, frCWKeys, fCallAlert,
  fNewCallAlert, fConfigStorage, fRbnFilter, fRbnMonitor, fRbnServer,
  fRadioMemories, fAddRadioMemory, fException, fCommentToCall,
  fNewCommentToCall, fFindCommentToCall, frExportPref, fExportPref,
  fWorkedGrids, fPropDK0WCY, fRemind, fContest, fMonWsjtx, fXfldigi,
  dMembership, dSatellite, uRigControl, uRotControl, azidis3, aziloc, fDOKStat,
  fCabrilloExport, uDbUtils, dQTHProfile, uConnectionInfo, znacmech, gline2,
  fDbSqlSel, fProgress, fDbError, fCountyStat;
var
  Splash    : TfrmSplash;
  SFL       : integer;
  AProcess  : TProcess;
  index     : integer;
  p         : TStringList;
  c         : integer;
  s         : string;
// that is what we never do !!  -> {$IFDEF WINDOWS}{$R cqrlog.rc}{$ENDIF}

{$R *.res}

begin
  Writeln(LineEnding+'Cqrlog Ver:',cVERSION,' Build:',cBuild,' Date:',cBUILD_DATE+LineEnding);
  try
    p := TStringList.Create;
    AProcess := TProcess.Create(nil);
    s:=FindDefaultExecutablePath('pidof');
    AProcess.Executable := s;
    AProcess.Parameters.Clear;
    AProcess.Parameters.Add('cqrlog');
    //Writeln('AProcess.Executable: ',AProcess.Executable,' Parameters: ',AProcess.Parameters.Text);
    AProcess.Options:=AProcess.Options+[poUsePipes, poWaitonexit];
    AProcess.Execute;
    p.clear;
    p.LoadFromStream(AProcess.Output);
    //writeln(p.text);
    c:=WordCount('Pid: '+ p.text,[' ']); // ensure that WordCount has always non empty string
  finally
    p.free;
    AProcess.Free;
  end;
  //writeln(c);

  // Fix default BidiMode (this might be ok already in laz 3.x but leaving here makes no harm)
  // see http://bugs.freepascal.org/view.php?id=22044
  Application.BidiMode:= bdLeftToRight;

  Application.CaseSensitiveOptions:=False;
  if ((Application.HasOption('v','version')) or (Application.HasOption('h','help'))) then
     Begin
        if Application.HasOption('v','version') then exit;
        Writeln;
        Writeln('-h     --help           Print this help and exit');
        Writeln('-r KEY --remote=KEY     Start with remote mode KEY= one of J,M,K');
        Writeln('                        (for KEY see: NewQSO shortcut keys)');
        Writeln('-q     --quiet          Start without spash at beginning');
        Writeln('-v     --version        Print version and exit');
        Writeln('       --debug=NR       Set debug level to NR');
        Writeln;
        Writeln('Debug level NRs:');
        Writeln('     0  No debug messages');
        Writeln('     1  All debug messages');
        Writeln('     2  All debug messages + some additional RBNmonitor & DXCluster debugs');
        Writeln('Negative values can be combined (binary bitwise OR)');
        Writeln('    -2  AdifImport & ImportProgress debug messages');
        Writeln('    -4  Wsjtx remote & Worked grids debug messages');
        Writeln('    -8  CW keying & TRXControl debug messages');
        Writeln('   -16  Grayline map RBN debug messages');
        Writeln;
        Exit;
     end;

  Application.Initialize;

  if (c > 2) then
       Begin
         Writeln();
         Writeln('Cqrlog is already running !!'+LineEnding);

         Writeln('If you want to run several Cqrlogs at same machine you must make');
         Writeln('several copies of /usr/bin/cqrlog using different names for all.'+LineEnding);

         Writeln('If you then want to use same log database for all Cqrlogs');
         Writeln('you need to set common database server for logs and use ');
         Writeln('"Preferences/program/Configuretion storage settings" to separate');
         Writeln('each Cqrlog saving their own settings.');
         ShowMessage('Cqrlog is already running !!');
         Exit;
       end;



  if (not Application.HasOption('q','quiet')) then
  Begin
    Splash := TfrmSplash.create(application);
    Splash.show;
    for SFL:=1 to 5 do
     Begin
       sleep(100);
       Application.ProcessMessages;
     end;
  end;

  Application.CreateForm(TfrmNewQSO, frmNewQSO);
  Application.CreateForm(TdmData, dmData);
  Application.CreateForm(TdmLogUpload, dmLogUpload);
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TdmUtils, dmUtils);
  Application.CreateForm(TdmDXCC, dmDXCC);
  Application.CreateForm(TdmDXCluster, dmDXCluster);
  Application.CreateForm(TfrmGrayline, frmGrayline);
  Application.CreateForm(TfrmCallbook, frmCallbook);
  Application.CreateForm(TfrmTRXControl, frmTRXControl);
  Application.CreateForm(TfrmDXCluster, frmDXCluster);
  Application.CreateForm(TfrmQSODetails, frmQSODetails);
  Application.CreateForm(TfrmBandMap, frmBandMap);
  Application.CreateForm(TfrmPropagation, frmPropagation);
  Application.CreateForm(TfrmCWKeys, frmCWKeys);
  Application.CreateForm(TfrmSCP, frmSCP);
  Application.CreateForm(TfrmRotControl, frmRotControl);
  Application.CreateForm(TfrmLogUploadStatus, frmLogUploadStatus);
  Application.CreateForm(TfrmCWType, frmCWType);
  Application.CreateForm(TfrmRbnMonitor, frmRbnMonitor);
  Application.CreateForm(TfrmWorkedGrids, frmWorkedGrids);
  Application.CreateForm(TfrmPropDK0WCY, frmPropDK0WCY);
  Application.CreateForm(TfrmReminder, frmReminder);
  Application.CreateForm(TfrmContest, frmContest);
  Application.CreateForm(Tfrmxfldigi, frmxfldigi);
  Application.CreateForm(TdmMembership, dmMembership);
  Application.CreateForm(TdmSatellite, dmSatellite);
  Application.CreateForm(TfrmProgress, frmProgress);

   if (not Application.HasOption('q','quiet')) then
  Begin
    Splash.Image2.Visible:=true;
    for SFL:=1 to 5 do
     Begin
       sleep(100);
       Application.ProcessMessages;
     end;
    Splash.ImageVText(Splash.Image1,$FF0000);
    for SFL:=1 to 15 do
     Begin
       sleep(100);
       Application.ProcessMessages;
     end;
    Splash.close;
    Splash.Release;
  end;
  Application.Run;
end.

