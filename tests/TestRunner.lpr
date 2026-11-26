program TestRunner;

{$mode objfpc}{$H+}

uses
  consoletestrunner,
  TestHelloWorld;

var
  Application: TTestRunner;

begin
  Application := TTestRunner.Create(nil);
  try
    Application.Initialize;
    Application.Run;
  finally
    Application.Free;
  end;
end.