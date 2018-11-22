unit uReplaceInFile;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ESBPCSEdit, ESBPCSNumEdit, uError, Dutils;

type
  TMainForm = class(TForm)
    GoButton: TButton;
    Label1: TLabel;
    EditOrg: TEdit;
    Label2: TLabel;
    EditReplace: TEdit;
    Label3: TLabel;
    EditFileName: TEdit;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    Memo1: TMemo;
    Label4: TLabel;
    ESBIntEditMax: TESBIntEdit;
    procedure FormCreate(Sender: TObject);
    procedure EditFileNameClick(Sender: TObject);
    procedure GoButtonClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

  implementation

{$R *.DFM}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  InitialiseLogFile;
  Caption := ExtractFileName( ChangeFileExt( ParamStr( 0 ), '' ) );
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
FinaliseLogFile;
end;

procedure TMainForm.EditFileNameClick(Sender: TObject);
begin
  with OpenDialog1 do begin
    if execute then begin
      EditFileName.Text := expandfilename( filename );  
    end;
  end;
end;

procedure TMainForm.GoButtonClick(Sender: TObject);
var
  f, g: TextFile;
  j, k, LineNr : Integer;
  S, ReplaceText, OrgText: String;
  MaxNrOfReplacementsIsDefined, SpecificLine, DeleteLine: Boolean;
begin
  with SaveDialog1 do begin
    if ( Mode = Batch ) or ( ( Mode = Interactive ) and Execute ) then begin
      if ( Mode = Batch ) then
        FileName := ParamStr( 4 );
      AssignFile( f, EditFileName.Text ) ; Reset( f );
      AssignFile( g, FileName ); Rewrite( g );
      k := 0; LineNr := 0;
      SpecificLine := ( ESBIntEditMax.AsInteger < 0 );
      WriteToLogFileFmt(  'SpecificLine: %d.', [ESBIntEditMax.AsInteger] );
      MaxNrOfReplacementsIsDefined := ( ESBIntEditMax.AsInteger > 0 ) or SpecificLine;
      OrgText := EditOrg.Text; //StringReplace( EditOrg.Text, '#13#10', sLineBreak, [rfReplaceAll, rfIgnoreCase]);
      ReplaceText := StringReplace( EditReplace.Text, '#13#10', sLineBreak, [rfReplaceAll, rfIgnoreCase]);
      while ( not EOF( f ) ) do begin
        Readln( f, S );  Inc( LineNr ); DeleteLine := false;
        if ( not MaxNrOfReplacementsIsDefined ) or
           ( MaxNrOfReplacementsIsDefined and (k < ESBIntEditMax.AsInteger ) ) or
           ( SpecificLine and ( LineNr = -ESBIntEditMax.AsInteger ) ) then begin
          j := pos( UpperCase( OrgText ), UpperCase( S ) );
          if ( j > 0 ) then begin // OrgText is gevonden in S
            Inc( k );
            DeleteLine := ( pos( 'DELETE THIS LINE', UpperCase( ReplaceText ) ) > 0 );
            if not DeleteLine then begin  // Vervang tekst in S
              WriteToLogFileFmt(  'Replaced S="%s".', [S] );
              S := StringReplace( S, OrgText, ReplaceText, [rfReplaceAll, rfIgnoreCase]);
              WriteToLogFileFmt(  'With S="%s".', [S] );
            end;
          end;
        end;
        if not DeleteLine then
          Writeln( g, S );
      end; {while}
      CloseFile( f ); CloseFile( g );
      WriteToLogFileFmt(  'Nr of replaced lines = %d', [k] );
      if (k = 0 ) then
        MessageDlg('No replacements made for string' +  #13#10 + '[' + EditOrg.Text + ']' , mtError, [mbOk], 0)
      else if ( Mode = Interactive ) then
        MessageDlg( IntToStr( k ) + ' Replacements made for string' +  #13#10 + '[' + EditOrg.Text + ']' , mtInformation, [mbOk], 0);
    end;
  end;
end;

initialization
 
finalization

end.
