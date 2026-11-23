unit TestHelloWorld;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry;

type
  TTestHelloWorld = class(TTestCase)
  published
    procedure TestHelloWorld;
    procedure TestFail;
  end;

implementation

procedure TTestHelloWorld.TestHelloWorld;
begin
  AssertEquals('Hello World', 'Hello World');
end;

procedure TTestHelloWorld.TestFail;
begin
  AssertEquals('This test fails',
    'Hello World', 'Fail');
end;

initialization
  RegisterTest(TTestHelloWorld);

end.