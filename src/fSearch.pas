(*
 ***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *                                                                         *
 ***************************************************************************
*)


unit fSearch;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, ExtCtrls;

type

  { TfrmSearch }

  TfrmSearch = class(TForm)
    btnCancel: TButton;
    btnSearch: TButton;
    chkSortByDate : TCheckBox;
    chkInclude: TCheckBox;
    cmbSearch: TComboBox;
    edtText: TEdit;
    GroupBox1: TGroupBox;
    grbOptions: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    mHelp: TMemo;
    Panel1: TPanel;
    procedure FormCloseQuery(Sender : TObject; var CanClose : boolean);
    procedure FormShow(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure cmbSearchChange(Sender: TObject);
    procedure edtTextKeyPress(Sender: TObject; var Key: char);
  private
    procedure LoadSettings;
    procedure SaveSettings;
  public
    { public declarations }
  end; 

var
  frmSearch: TfrmSearch;

implementation

{ TfrmSearch }
uses dData, fMain, dUtils, uMyIni;

procedure TfrmSearch.FormShow(Sender: TObject);
begin
  dmUtils.LoadFontSettings(self);
  cmbSearch.Items.Add('QSO Date');
  cmbSearch.Items.Add('Callsign');
  cmbSearch.Items.Add('Name');
  cmbSearch.Items.Add('QTH');
 // if dmData.IsFilter then
 //   cmbSearch.ItemIndex := 1
 // else
  LoadSettings;
  edtText.SetFocus;
  cmbSearchChange(nil);
  if dmData.IsFilter and (not dmData.IsSFilter) then
  begin
    mHelp.Visible := True;
    Height := Height+90;
    chkSortByDate.Enabled := False;
    chkSortByDate.Checked := False;
  end
end;

procedure TfrmSearch.FormCloseQuery(Sender : TObject; var CanClose : boolean);
begin
  SaveSettings
end;

procedure TfrmSearch.btnSearchClick(Sender: TObject);
var
  sql : String = '';
  c   : integer;

procedure NoneFound;
Begin
  ShowMessage(edtText.Text + ' not found');
  frmMain.acCancelFilterExecute(nil);
  sql:='';
  Close;
end;

begin
  SaveSettings;
  if edtText.Text = '' then
    exit;
  if dmData.SortType = stDate then
    sql := 'select * from view_cqrlog_main_by_qsodate '
  else
    sql := 'select * from view_cqrlog_main_by_callsign ';

  case cmbSearch.ItemIndex of
    0 : begin
          if dmData.IsFilter and (not dmData.IsSFilter) then
          begin
            if  dmData.QueryLocate(dmData.qCQRLOG,'qsodate',edtText.Text,True) then
            begin
              frmMain.sbMain.Panels[2].Text := 'FSearch is ACTIVE!';
              Close;
              exit
            end
            else
              NoneFound
          end
          else begin
            sql := sql + ' where qsodate = '+ QuotedStr(edtText.Text);
            if chkSortByDate.Checked then
              sql := sql + ' order by qsodate'
          end
        end;
    1 : begin
          if dmData.IsFilter and (not dmData.IsSFilter) then
          begin
            if dmData.QueryLocate(dmData.qCQRLOG,'callsign',edtText.Text,False,not chkInclude.Checked) then
            begin
              frmMain.sbMain.Panels[2].Text := 'FSearch is ACTIVE!';
              Close;
              exit
            end
            else
              NoneFound
          end
          else begin
            if chkInclude.Checked then
              sql := sql + ' where (callsign like ''%' + edtText.Text + '%'')'
            else
              sql := sql + ' where callsign = '+ QuotedStr(edtText.Text);
              if chkSortByDate.Checked then
                sql := sql + ' order by qsodate'
          end
        end;
    2 : begin
          if dmData.IsFilter and (not dmData.IsSFilter) then
          begin
            if dmData.QueryLocate(dmData.qCQRLOG,'name',edtText.Text,False,not chkInclude.Checked) then
            begin
              frmMain.sbMain.Panels[2].Text := 'FSearch is ACTIVE!';
              Close;
              exit
            end
            else
              NoneFound
          end
          else begin
            if chkInclude.Checked then
              sql := sql + ' where (name like ''%' + edtText.Text + '%'')'
            else
              sql := sql + ' where name = '+ QuotedStr(edtText.Text);
            if chkSortByDate.Checked then
             sql := sql + ' order by qsodate'
          end
        end;
    3 : begin
          if dmData.IsFilter and (not dmData.IsSFilter) then
          begin
            if dmData.QueryLocate(dmData.qCQRLOG,'qth',edtText.Text,False,not chkInclude.Checked) then
            begin
              frmMain.sbMain.Panels[2].Text := 'FSearch is ACTIVE!';
              Close;
              exit
            end
            else
              NoneFound
          end
          else begin
            if chkInclude.Checked then
              sql := sql + ' where (qth like ''%' + edtText.Text + '%'')'
            else
              sql := sql + ' where qth = '+ QuotedStr(edtText.Text);
            if chkSortByDate.Checked then
              sql := sql + ' order by qsodate'
          end
        end
  end; //case

  if sql<>'' then
   begin
     writeln(sql);
    try
      dmData.qCQRLOG.DisableControls;
      dmData.Q.Close;
      if dmData.trQ.Active then dmData.trQ.Rollback;
      dmData.Q.SQL.Text := sql + ' LIMIT 1';
      dmData.trQ.StartTransaction;
      dmData.Q.Open;
      c:= dmData.Q.Fields[0].AsInteger;
      dmData.qCQRLOG.Close;
      dmData.trCQRLOG.Rollback;
    finally
      dmData.qCQRLOG.EnableControls
    end;

    if c = 0 then
     NoneFound
    else
     begin
      dmData.qCQRLOG.DisableControls;
      try
        dmData.qCQRLOG.Close;
        dmData.trCQRLOG.Rollback;
        dmData.qCQRLOG.SQL.Text := sql;
        dmData.trCQRLOG.StartTransaction;
        dmData.qCQRLOG.Open;
      finally
        dmData.IsFilter  := True;
        dmData.IsSFilter := True;
        frmMain.sbMain.Panels[2].Text := 'Search is ACTIVE!';
        frmMain.RefreshQSODXCCCount;
        dmData.qCQRLOG.EnableControls;
        Close
      end
     end;
    frmMain.CheckAttachment;
   end;
end;

procedure TfrmSearch.cmbSearchChange(Sender: TObject);
begin
  if cmbSearch.ItemIndex = 1 then
    edtText.CharCase := ecUppercase
  else
    edtText.CharCase := ecNormal;
  if cmbSearch.ItemIndex = 0 then
    grbOptions.Enabled := False
  else
    grbOptions.Enabled := True
end;

procedure TfrmSearch.edtTextKeyPress(Sender: TObject; var Key: char);
begin
  if key = #13 then
  begin
    btnSearch.Click;
    key := #0
  end
end;

procedure TfrmSearch.LoadSettings;
begin
  chkSortByDate.Checked := cqrini.ReadBool('Search','SortByDate',False);
  chkInclude.Checked    := cqrini.ReadBool('Search','Include',False);
  cmbSearch.ItemIndex   := cqrini.ReadInteger('Search','Index',1)
end;

procedure TfrmSearch.SaveSettings;
begin
  cqrini.WriteBool('Search','SortByDate',chkSortByDate.Checked);
  cqrini.WriteBool('Search','Include',chkInclude.Checked);
  cqrini.WriteInteger('Search','Index',cmbSearch.ItemIndex)
end;


initialization
  {$R *.lfm}

end.

