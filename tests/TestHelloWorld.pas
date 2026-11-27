unit TestHelloWorld;

{$mode objfpc}{$H+}

interface

uses
  Classes, fpcunit, testregistry;

type
  TTestHelloWorld = class(TTestCase)
  published
    procedure TestHelloWorld;
  end;

implementation

procedure TTestHelloWorld.TestHelloWorld;
begin
  AssertEquals('Hello World', 'Hello World');
end;

initialization
  RegisterTest(TTestHelloWorld);

end.
