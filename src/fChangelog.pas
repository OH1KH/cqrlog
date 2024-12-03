unit fChangelog;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, LazHelpHTML, IpHtml, Ipfilebroker;

type

  { TfrmChangelog }

  TfrmChangelog = class(TForm)
    Button1: TButton;
    IpFileDataProvider1: TIpFileDataProvider;
    IpHtmlPanel1: TIpHtmlPanel;
    Panel1: TPanel;
  private
    { private declarations }
  public
    { public declarations }
    Procedure ViewChangelog;
    Procedure ViewEmptylog;
  end; 

var
  frmChangelog: TfrmChangelog;

implementation

{$R *.lfm}

{ TfrmChangelog }
uses dData;


Procedure TfrmChangelog.ViewChangelog;
Begin
  Self.Caption:='CqrlogAlpha - Changelog';
  IpHtmlPanel1.OpenURL(expandLocalHtmlFileName(dmData.ShareDir+'changelog.html'));
end;

Procedure TfrmChangelog.ViewEmptyLog;
var
    e       : String =
'<HTML lang="en">'+
'<HEAD>'+
'<meta charset="utf-8">'+
'<title>New empty log: Check settings!</title>'+
'</HEAD>'+
'<BODY>'+
'<H3 style="color:red;"> &nbsp;&nbsp;&nbsp;New empty log: Check settings!</H3>'+
'<HR>'+
'<P>'+
'It seems that you have <strong>not set Station CALLSIGN</strong> for this log.<BR>'+
'<BR>'+
'CqrlogAlpha has <strong>own settings for every log</strong>.<BR>'+
'You can copy settings between logs using window:<BR>'+
'<UL><LI>Database Connect/Utils/settings/import<->export using an external file when logs are not open.</LI>'+
'<LI>Copy settings from existing log at new log creation phase.</LI></UL>'+
'<BR>'+
'<HR>'+
'For this new log check now from Main menu: <strong>File/Preferences </strong>at least following Tabs:</P>'+
'<P><UL><LI style="list-style: square;text-align:left; color: green;" >'+
'PROGRAM:</LI>'+
'<UL><LI style="text-align:left; color: brown;">'+
'Basic settings how CqrlogAlpha works with this log</LI></UL>'+
'<LI style="list-style: square;text-align:left; color: green;" >'+
'STATION:</LI>'+
'<UL><LI style="text-align:left; color: brown;">'+
'Your station information for this log</LI></UL>'+
'<LI style="list-style: square;text-align:left; color: green;" >'+
'BANDS:</LI>'+
'<UL><LI style="text-align:left; color: brown;"> '+
'By default CqrlogAlpha uses Region1 band settings.<BR>'+
'If you are in other region please check bands/frequencies<BR>'+
'to set correct band start and end frequencies.<BR>'+
'This will affect to all CqrlogAlpha operations.</LI></UL>'+
'<LI style="list-style: square;text-align:left; color: green;" >'+
'TRX CONTROL:</LI>'+
'<UL><LI style="text-align:left; color: brown;">'+
'Settings if you want CqrlogAlpha to communicate with<BR>'+
'your rig using CAT control.</LI></UL>'+
'<LI style="list-style: square;text-align:left; color: green;" >'+
'EXTERNAL VIEWERS:</LI>'+
'<UL><LI style="text-align:left; color: brown;"> '+
'Programs that CqrlogAlpha uses for viewing various documents</LI></UL>'+
'</UL></P>'+
'<P>'+
'For other Preferences/Tabs: Set their values by your needs.'+
'</P>'+
'<HR>'+
'<P>'+
'<a style="color: red;font-weight:bold;">PLEASE</a> use Main menu:<a style="color: red;font-weight:bold;"> HELP/HELP INDEX</a> for more help for settings and operation.<BR>'+
'Help opens into your web browser.'+
'</P>'+
'<P style="color: red;font-weight:bold;">73, gl DX!</P></BODY></HTML>';
Begin
  Self.Caption:='New log: Check settings!';
  IpHtmlPanel1.SetHtmlFromStr(e);
end;

end.

