(*
 ***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License.        *
 *                                                                         *
 ***************************************************************************
*)


unit fSplash;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls,
  buttons, ExtCtrls;

type

  { TfrmSplash }

  TfrmSplash = class(TForm)
    Image1: TImage;
    Image2: TImage;
    procedure FormCreate(Sender: TObject);

  private
    { private declarations }
  public
    { public declarations }
    procedure ImageVText(I:TImage;c:Tcolor=clRed);
  end;

const
  VersionPos: TPoint = (X:270; Y:245);
  VersionStyle: TTextStyle =
   (
     Alignment  : taCenter;
     Layout     : tlCenter;
     SingleLine : True;
     Clipping   : True;
     ExpandTabs : False;
     ShowPrefix : False;
     Wordbreak  : False;
     Opaque     : False;
     SystemFont : False;
     RightToLeft: False;
     EndEllipsis: False
   );
var
  frmSplash: TfrmSplash;

implementation
{$R *.lfm}

uses uVersion;

{ TfrmSplash }

procedure TfrmSplash.FormCreate(Sender: TObject);
begin
  Width  := Image1.Picture.Width;
  Height := Image1.Picture.Height;
end;

procedure TfrmSplash.ImageVText(I:Timage;c:Tcolor=clRed);
var
  ATextRect: TRect;
Begin
  ATextRect.TopLeft := VersionPos;
  ATextRect.BottomRight := Point(Width, Height);
  I.Picture.Bitmap.Canvas.Font.Style := [fsBold];
  I.Picture.Bitmap.Canvas.Font.Color := c;
  I.Picture.Bitmap.Canvas.Brush.Style:=bsClear;
  I.Picture.Bitmap.Canvas.TextRect(ATextRect, VersionPos.X, VersionPos.Y, cVERSION, VersionStyle);
  Application.ProcessMessages;
end;

end.

