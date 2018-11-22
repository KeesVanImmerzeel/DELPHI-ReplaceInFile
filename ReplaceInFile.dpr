program ReplaceInFile;

uses
  Forms,
  Sysutils,
  uError,
  uReplaceInFile in 'uReplaceInFile.pas' {MainForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Try
    Try
      if (( ParamCount = 4 ) or ( ParamCount = 5 )) then begin
        Mode := Batch;
        with MainForm do begin
          EditFileName.Text := ParamStr( 1 );
          EditOrg.Text := ParamStr( 2 );
          EditReplace.Text := ParamStr( 3 );
          if ( ParamCount = 5 ) then begin
            ESBIntEditMax.Text := ParamStr( 5 );
            {-ParamStr( 4 ): resultfilename, zie unit 'uAdjustCbodem' }
            WriteToLogFileFmt(  'ESBIntEditMax.Text = [%s].', [ESBIntEditMax.Text] );
          end;
        end;
      end; {if ( ParamCount = 4 )}
      if ( Mode = Interactive ) then 
        Application.Run
      else
        MainForm.GoButton.click;
    Except
      WriteToLogFileFmt( 'Error in application: [%s].', [ApplicationFileName] );
    end;
  Finally

  end;
end.
