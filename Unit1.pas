unit Unit1;

{$MODE Delphi}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type
  TForm1 = class(TForm)
    Image1: TImage;
    L_Sektor: TLabel;
    P_Name: TPanel;
    Label1: TLabel;
    E_Name: TEdit;
    M_Anz: TMemo;
    P_Schiff: TPanel;
    M_Schiff1: TMemo;
    M_Schiff2: TMemo;
    M_Info: TMemo;
    P_Auftrag: TPanel;
    L_Links: TLabel;
    M_Auftrag: TMemo;
    L_Rechts: TLabel;
    P_BeEntl: TPanel;
    M_BeEntl: TMemo;
    P_Code: TPanel;
    E_Code: TEdit;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

type
  str10  = string[10];
  str20  = string[20];
  str40  = string[40];
  str80  = string[80];
  auftr  = record                                                               //  Ein Auftrag
             startsek : byte;
             startort : str40;
             zielsek  : byte;
             zielort  : str40;
             ladung   : str40;
             lohn     : longint;
            end;
  wauftr = record                                                               //  Ein Auftrag
             nr       : longint;
             startsek : byte;
             startort : str40;
             zielsek  : byte;
             zielort  : str40;
             ladung   : str40;
             lohn     : longint;
            end;
  ereign = record                                                               //  Ein Ereignis
             was      : str40;
             defekt   : str40;
             kosten   : longint;
            end;
  Dock = record                                                                 //  Angedocktes Schiff
             Nr       : longint;
             Captain  : str40;
             Typ      : str10;
             Guthaben : longint;
             Legal    : integer;
             LadLegal : str10;
             Illegal  : integer;
             LadIlleg : str10;
            end;
var
  einn     :string[30];                   { name der eingabedatei }
  einf     :text;                         { filediskriptor        }
  ausn     :string[30];                   { name der eingabedatei }
  ausf     :text;                         { filediskriptor        }

  ProgrammPath: string;                                                         //  Pfad des Programm's
  ServerPath: string;                                                           //  Pfad des Serververzeichnisses
  BServerPath: string;                                                          //  Pfad des Serververzeichnisses
  BServerDa  : boolean;                   //  2. Server da
  DiskPath: string;                                                             //  Pfad der Disk

  Sektor   :byte;                         { Sektor des Rechners }
  IniSektor:byte;                         { Sektor aus der Ini-Datei }

  bef      :char;
  prgwo    :byte;                         { Wo ist das Programm:
                                            0 = Identifizieren
                                            1 = Auftrag suchen
                                            2 = Start quittieren
                                            3 = Ziel bearbeiten }

//  uprg     :byte;                         { Ablaufmerker Teilprogramme }
  A_Auftr    :array[1..1500] of auftr;    { A-Aufträge }
  A_Auftr_vb :integer;                    { Auftragsliste voll bis ... }
  B_Auftr    :array[1..1500] of auftr;    { B-Aufträge }
  B_Auftr_vb :integer;                    { Auftragsliste voll bis ... }
  Ereignis   :array[1..1000] of ereign;   { Ereignisliste }
  Ereign_vb  :integer;                    { Ereignisliste voll bis ... }
  Ereig_Akt  :integer;                    { aktives Ereignis }
  A_Code     :array[1..500] of str10;     { Code für Schiff A }
  A_Code_vb  :integer;                    { Codeliste voll bis ... }
  B_Code     :array[1..500] of str10;     { Code für Schiff B }
  B_Code_vb  :integer;                    { Codeliste voll bis ... }

  W_Auftr    :array[1..4] of wauftr;      { Aufträge zur Auswahl}
  W_Aktiv    :byte;                       { gewählter Auftrag }
  W_Max      :byte;                       { maximale Auftragsanzahl }

  Schiff     :Dock;                       { Schiff das angelegt hat }
  ACodeUse   :array[1..500] of boolean;
  BCodeUse   :array[1..500] of boolean;
  rfid       :string;                     { Nr vom RFID }

//******************************************************************************
function StrToIntDW (egstr : string) : integer;
var
  erg : integer;
  i   : integer;
  flg : boolean;
begin
  while(copy(egstr,length(egstr),1) = ' ') do begin
    egstr:=copy(egstr,1,length(egstr)-1);
  end;
  if (length(egstr) = 0) then begin
      erg:=9999;
  end else begin
    flg:=true;
    for i:=1 to length(egstr) do begin
      if (ord(egstr[i]) < ord('0')) then begin
        flg:=false;
      end;
      if (ord(egstr[i]) > ord('9')) then begin
        flg:=false;
      end;
    end;
    if (flg) then begin
      erg:=StrToInt(egstr);
    end else begin
      erg:=9999;
    end;
  end;
  StrToIntDW:=erg;
end;
//******************************************************************************
procedure UseLesen;                                                             //  Use-Flags lesen
var
  egstr : string;
  nr    : word;
begin
  if (sektor >= 5) and (sektor <= 7) then begin                                 //? Illegaler Sektor
    for nr:=1 to A_Code_vb do begin                                             //S ... Für alle Codes
      ACodeUse[nr]:=false;
    end;
    case sektor of                                                              //> Sektor
      5: begin
           assign(einf,ServerPath+'\5_CA_use.txt');                             //  Dateiname festlegen
         end;
      6: begin
           assign(einf,ServerPath+'\6_CA_use.txt');                             //  Dateiname festlegen
         end;
      7: begin
           assign(einf,ServerPath+'\7_CA_use.txt');                             //  Dateiname festlegen
         end;
    end;                                                                        //E case Sektor
    {$I-}
    reset(einf);                                                                //  Auftragsdatei öffnen
    {$I+}
    if IOResult = 0 then begin                                                  //? Datei vorhanden
      nr:=1;
      while not EOF(einf) do begin                                              //S ... bis Dateiende
        readln(einf,egstr);                                                     //  Eine Zeile lesen
        if (egstr = 'true') then begin                                          //? Code benutzt
          ACodeUse[nr]:=true;
        end;
        inc(nr);
      end;                                                                      //E S.: ... bis Dateiende
      close(einf);                            {  Datei schlieáen }
    end;                                      {E if: Datei vorhanden }
    for nr:=1 to B_Code_vb do begin                                             //S ... Für alle Codes
      BCodeUse[nr]:=false;
    end;
    case sektor of                                                              //> Sektor
      5: begin
           assign(einf,ServerPath+'\5_CB_use.txt');                             //  Dateiname festlegen
         end;
      6: begin
           assign(einf,ServerPath+'\6_CB_use.txt');                             //  Dateiname festlegen
         end;
      7: begin
           assign(einf,ServerPath+'\7_CB_use.txt');                             //  Dateiname festlegen
         end;
    end;                                                                        //E case Sektor
    {$I-}
    reset(einf);                                                                //  Auftragsdatei öffnen
    {$I+}
    if IOResult = 0 then begin                                                  //? Datei vorhanden
      nr:=1;
      while not EOF(einf) do begin                                              //S ... bis Dateiende
        readln(einf,egstr);                                                     //  Eine Zeile lesen
        if (egstr = 'true') then begin                                          //? Code benutzt
          BCodeUse[nr]:=true;
        end;
        inc(nr);
      end;                                                                      //E S.: ... bis Dateiende
      close(einf);                            {  Datei schlieáen }
    end;                                      {E if: Datei vorhanden }
  end;                                                                          //E if: Illegaler Sektro
end;
//******************************************************************************
procedure AUseSchreiben;                                                         //  Use-Flags schreiben
var
  nr    : word;
begin
  if (sektor >= 5) and (sektor <= 7) then begin                                 //? Illegaler Sektor
    case sektor of                                                              //> Sektor
      5: begin
           assign(ausf,ServerPath+'\5_CA_use.txt');                             //  Dateiname festlegen
         end;
      6: begin
           assign(ausf,ServerPath+'\6_CA_use.txt');                             //  Dateiname festlegen
         end;
      7: begin
           assign(ausf,ServerPath+'\7_CA_use.txt');                             //  Dateiname festlegen
         end;
    end;                                                                        //E case Sektor
    {$I-}
    rewrite(ausf);                            {  Auftragsdatei schreiben }
    {$I+}
    if IOResult = 0 then begin                {? Datei vorhanden }
      for nr:=1 to A_Code_vb do begin                                           //S ... Für alle Codes
        if ACodeUse[nr] then begin                                              //? Code benutzt
          writeln(ausf,'true');
        end else begin
          writeln(ausf,'false');
        end;
      end;
      close(ausf);                            {  Datei schlieáen }
    end;                                      {E if: Datei vorhanden }
  end;                                                                          //E if: Illegaler Sektro
  if BServerDa then begin                                                       //? Server B
    case sektor of                                                              //> Sektor
      5: begin
           assign(ausf,BServerPath+'\5_CA_use.txt');                             //  Dateiname festlegen
         end;
      6: begin
           assign(ausf,BServerPath+'\6_CA_use.txt');                             //  Dateiname festlegen
         end;
      7: begin
           assign(ausf,BServerPath+'\7_CA_use.txt');                             //  Dateiname festlegen
         end;
    end;                                                                        //E case Sektor
    {$I-}
    rewrite(ausf);                            {  Auftragsdatei schreiben }
    {$I+}
    if IOResult = 0 then begin                {? Datei vorhanden }
      for nr:=1 to A_Code_vb do begin                                           //S ... Für alle Codes
        if ACodeUse[nr] then begin                                              //? Code benutzt
          writeln(ausf,'true');
        end else begin
          writeln(ausf,'false');
        end;
      end;
      close(ausf);                            {  Datei schlieáen }
    end;                                      {E if: Datei vorhanden }
  end;
end;
//******************************************************************************
procedure BUseSchreiben;                                                         //  Use-Flags schreiben
var
  nr    : word;
begin
  if (sektor >= 5) and (sektor <= 7) then begin                                 //? Illegaler Sektor
    case sektor of                                                              //> Sektor
      5: begin
           assign(ausf,ServerPath+'\5_CB_use.txt');                             //  Dateiname festlegen
         end;
      6: begin
           assign(ausf,ServerPath+'\6_CB_use.txt');                             //  Dateiname festlegen
         end;
      7: begin
           assign(ausf,ServerPath+'\7_CB_use.txt');                             //  Dateiname festlegen
         end;
    end;                                                                        //E case Sektor
    {$I-}
    rewrite(ausf);                            {  Auftragsdatei schreiben }
    {$I+}
    if IOResult = 0 then begin                {? Datei vorhanden }
      for nr:=1 to B_Code_vb do begin                                           //S ... Für alle Codes
        if BCodeUse[nr] then begin                                              //? Code benutzt
          writeln(ausf,'true');
        end else begin
          writeln(ausf,'false');
        end;
      end;
      close(ausf);                            {  Datei schlieáen }
    end;                                      {E if: Datei vorhanden }
    if BServerDa then begin                                                       //? Server B
      case sektor of                                                              //> Sektor
        5: begin
             assign(ausf,BServerPath+'\5_CB_use.txt');                             //  Dateiname festlegen
           end;
        6: begin
             assign(ausf,BServerPath+'\6_CB_use.txt');                             //  Dateiname festlegen
           end;
        7: begin
             assign(ausf,BServerPath+'\7_CB_use.txt');                             //  Dateiname festlegen
           end;
      end;                                                                        //E case Sektor
      {$I-}
      rewrite(ausf);                            {  Auftragsdatei schreiben }
      {$I+}
      if IOResult = 0 then begin                {? Datei vorhanden }
        for nr:=1 to B_Code_vb do begin                                           //S ... Für alle Codes
          if BCodeUse[nr] then begin                                              //? Code benutzt
            writeln(ausf,'true');
          end else begin
            writeln(ausf,'false');
          end;
        end;
        close(ausf);                            {  Datei schlieáen }
      end;                                      {E if: Datei vorhanden }
    end;                                                                          //E if: Illegaler Sektro
  end;
end;
//******************************************************************************
procedure AuftrSuchen;
var
  i  : integer;
  nr : integer;
begin
  if (schiff.typ = '1') then begin                                              //? Schiffstyp 1
    for i:=1 to 4 do begin                                                      //S ... 4 mal
      repeat                                                                    //S ... bis Auftrag gefunden
        nr:=random(A_Auftr_vb);                                                 //  Auftr„ge suchen
      until(nr > 0);                                                            //E S.: ... bis Auftrag
      W_Auftr[i].nr      := nr;                                                 //  Auftrag übertragen
      W_Auftr[i].startsek:= A_Auftr[nr].startsek;                               //  Auftrag übertragen
      W_Auftr[i].startort:= A_Auftr[nr].startort;
      W_Auftr[i].zielsek := A_Auftr[nr].zielsek;
      W_Auftr[i].zielort := A_Auftr[nr].zielort;
      W_Auftr[i].ladung  := A_Auftr[nr].ladung ;
      W_Auftr[i].lohn    := A_Auftr[nr].lohn;
    end;                                                                        //E S.: ... 4 mal }
  end else begin
    for i:=1 to 4 do begin                                                      //S ... 4 mal
      repeat                                                                    //S ... bis Auftrag gefunden
        nr:=random(B_Auftr_vb);                                                 //  Auftr„ge suchen
      until(nr > 0);                                                            //E S.: ... bis Auftrag
      W_Auftr[i].nr      := nr;                                                 //  Auftrag übertragen
      W_Auftr[i].startsek:= B_Auftr[nr].startsek;
      W_Auftr[i].startort:= B_Auftr[nr].startort;
      W_Auftr[i].zielsek := B_Auftr[nr].zielsek;
      W_Auftr[i].zielort := B_Auftr[nr].zielort;
      W_Auftr[i].ladung  := B_Auftr[nr].ladung ;
      W_Auftr[i].lohn    := B_Auftr[nr].lohn;
    end;                                                                        //E S.: ... 4 mal }
  end;
  W_Aktiv:=1;                                                                   //  Wir beginnen mit Auftrag 1
  W_Max:=4;                                                                     //  4 Aufträge zur Auswahl
end;
//******************************************************************************
function AuftrAnz(init : boolean) : byte;                                       //  Aufträge anzeigen
var
  erg : byte;
begin
  erg:=0;                                                                       //  Kein Datensatz gewählt
  if init then begin                                                            //? Init Anzeige
    //Form1.M_Info.Text:='abc';
    //Form1.M_Info.Text:=AnsiToUTF8('Bitte waehlen Sie einen Auftrag ...');
    Form1.M_Info.Text:='Bitte waehlen Sie einen Auftrag ...';
    Form1.P_Auftrag.Visible:=true;
    ;
  end else begin                                                                //N Init Anzeige
    if (ord(bef) = $0d) then begin                                              //? Cr
      if (W_Aktiv > 0) and (W_Aktiv <= W_Max) then begin                         //? Im Legalen Bereich
        erg:=W_Aktiv;                                                           //  Ergebnis melden
      end;
    end else begin                                                              //N Cr
      if (ord(bef) = $25) then begin                                            //? Pfeil rechts
        if (W_Aktiv > 1) then begin                                             //? Noch ein Auftrag
          dec(W_Aktiv);                                                         //  Auftrag - 1
        end;                                                                    //E if: Noch ein Auftrag
      end else begin                                                            //N Pfeil rechts
        if (ord(bef) = $27) then begin                                          //? Pfeil links
          if (W_Aktiv < W_Max) then begin                                       //? Noch ein Auftrag
            inc(W_Aktiv);                                                       //  Auftrag + 1
          end;                                                                  //E if: Noch ein Auftrag
        end;                                                                    //E if: Pfeil links
      end;                                                                      //E if: Pfeil rechts
    end;                                                                        //E if: Cr
  end;                                                                          //E if: Init Anzeige

  if (W_Aktiv = 0) or (W_Aktiv > W_Max) then begin                              //? Aktiver Auftrag nicht im Bereich
    W_Aktiv:=1;                                                                 //  Auftrag 1 setzen
  end;

  Form1.M_Auftrag.Text:=AnsiToUTF8('');
  Form1.M_Auftrag.Lines.Add(AnsiToUTF8(''));
  Form1.M_Auftrag.Lines.Add(AnsiToUTF8(''));
  Form1.M_Auftrag.Lines.Add(AnsiToUTF8('Auftrag '+IntToStr(W_Aktiv)+' von '+IntToStr(W_Max)));   //  Kopfzeile
  Form1.M_Auftrag.Lines.Add(AnsiToUTF8(''));
  Form1.M_Auftrag.Lines.Add(AnsiToUTF8('Nr.: ' + IntToStr(W_Auftr[W_Aktiv].nr)));
  Form1.M_Auftrag.Lines.Add(AnsiToUTF8(W_Auftr[W_Aktiv].Ladung));
  Form1.M_Auftrag.Lines.Add(AnsiToUTF8('Von ' + W_Auftr[W_Aktiv].Startort + ' in Sektor ' + IntToStr(W_Auftr[W_Aktiv].StartSek)));
  Form1.M_Auftrag.Lines.Add(AnsiToUTF8('Nach ' + W_Auftr[W_Aktiv].Zielort + ' in Sektor ' + IntToStr(W_Auftr[W_Aktiv].ZielSek)));
  Form1.M_Auftrag.Lines.Add(AnsiToUTF8(''));
  Form1.M_Auftrag.Lines.Add(AnsiToUTF8(IntToStr(W_Auftr[W_Aktiv].Lohn) + ' Credits'));
  if (erg > 0) then begin                                                       //? Datensatz gewählt
    Form1.L_Links.Caption:='!';                                                 //  gewählt
    Form1.L_Rechts.Caption:='!';
  end else begin                                                                //N Datensatz gewählt
    if W_Aktiv = 1 then begin                                                   //? Kein Datensatz links ?
      Form1.L_Links.Caption:=' ';                                               //  Pfeil löschen
    end else begin
      Form1.L_Links.Caption:='<';                                               //  Pfeil setzen
    end;
    if W_Aktiv >= W_Max then begin                                              //? Kein Datensatz rechts ?
      Form1.L_Rechts.Caption:=' ';                                              //  Pfeil löschen
    end else begin
      Form1.L_Rechts.Caption:='>';                                              //  Pfeil setzen
    end;
  end;                                                                          //E if: Datensatz gewählt
  AuftrAnz:=erg;
end;
//******************************************************************************
function datsc : byte;                      {  Daten in Datei schreiben }
var
  erg : byte;                               { Ergebnis: 1 = OK; ff = Fehler }
begin
  erg:=1;                                   {  Noch kein Fehler }
  assign(ausf,ServerPath+'\Dat_'+inttostr(Schiff.Nr)+'.txt'); {  Handelsdatei schreiben }
  {$I-}
  rewrite(ausf);                            {  Auftragsdatei schreiben }
  {$I+}
  if IOResult = 0 then begin                {? Datei vorhanden }
    writeln(ausf,'Captain');                {  Captain setzen }
		writeln(ausf,Schiff.Captain);
    writeln(ausf,'Raumschiff');             {  Raumschiff setzen }
		writeln(ausf,Schiff.Typ);
    writeln(ausf,'Guthaben');               {  Guthaben setzen }
		writeln(ausf,Schiff.Guthaben);
    writeln(ausf,'Legaler Auftrag');        {  legalen Auftrag setzen }
		writeln(ausf,Schiff.Legal);
    writeln(ausf,'Geladen?');               {  Geladen? }
		writeln(ausf,Schiff.LadLegal);
    writeln(ausf,'Illegaler Auftrag');      {  ilegalen Auftrag setzen }
		writeln(ausf,Schiff.Illegal);
    writeln(ausf,'Geladen?');               {  Geladen? }
		writeln(ausf,Schiff.LadIlleg);
    close(ausf);                            {  Datei schlieáen }

    assign(ausf,ServerPath+'\Log_'+inttostr(Schiff.Nr)+'.txt'); {  Handelsdatei schreiben }
    {$I-}
    append(ausf);                            {  Auftragsdatei schreiben }
    {$I+}
    if IOResult = 0 then begin                {? Datei vorhanden }
      writeln(ausf,'----- Sektor:' + inttostr(sektor) + ' ------');
      writeln(ausf,'Captain');                {  Captain setzen }
			writeln(ausf,Schiff.Captain);
      writeln(ausf,'Raumschiff');             {  Raumschiff setzen }
			writeln(ausf,Schiff.Typ);
      writeln(ausf,'Guthaben');               {  Guthaben setzen }
			writeln(ausf,Schiff.Guthaben);
      writeln(ausf,'Legaler Auftrag');        {  legalen Auftrag setzen }
			writeln(ausf,Schiff.Legal);
      writeln(ausf,'Geladen?');               {  Geladen? }
			writeln(ausf,Schiff.LadLegal);
      writeln(ausf,'Illegaler Auftrag');      {  ilegalen Auftrag setzen }
			writeln(ausf,Schiff.Illegal);
      writeln(ausf,'Geladen?');               {  Geladen? }
			writeln(ausf,Schiff.LadIlleg);
      close(ausf);                            {  Datei schlieáen }
    end else begin                            {N Datei vorhanden }
      {$I-}
      rewrite(ausf);                            {  Auftragsdatei schreiben }
      {$I+}
      if IOResult = 0 then begin                {? Datei vorhanden }
        writeln(ausf,'----------------------');
        writeln(ausf,'Captain');                {  Captain setzen }
				writeln(ausf,Schiff.Captain);
        writeln(ausf,'Raumschiff');             {  Raumschiff setzen }
				writeln(ausf,Schiff.Typ);
        writeln(ausf,'Guthaben');               {  Guthaben setzen }
				writeln(ausf,Schiff.Guthaben);
        writeln(ausf,'Legaler Auftrag');        {  legalen Auftrag setzen }
				writeln(ausf,Schiff.Legal);
        writeln(ausf,'Geladen?');               {  Geladen? }
				writeln(ausf,Schiff.LadLegal);
        writeln(ausf,'Illegaler Auftrag');      {  ilegalen Auftrag setzen }
				writeln(ausf,Schiff.Illegal);
        writeln(ausf,'Geladen?');               {  Geladen? }
				writeln(ausf,Schiff.LadIlleg);
        close(ausf);                            {  Datei schlieáen }
      end else begin                            {N Datei vorhanden }
        erg:=$ff;                             {  Fehler setzen }
      end;                                      {E if: Datei vorhanden }
    end;                                      {E if: Datei vorhanden }
    //  Info erzeugen
    assign(ausf,ServerPath+'\info\Dat_'+inttostr(Schiff.Nr)+'.txt'); {  Handelsdatei schreiben }
    {$I-}
    rewrite(ausf);                            {  Auftragsdatei schreiben }
    {$I+}
    if IOResult = 0 then begin                {? Datei vorhanden }
      writeln(ausf,'Captain');                {  Captain setzen }
  		writeln(ausf,Schiff.Captain);
      writeln(ausf,'Raumschiff');             {  Raumschiff setzen }
  		writeln(ausf,Schiff.Typ);
      writeln(ausf,'Guthaben');               {  Guthaben setzen }
  		writeln(ausf,Schiff.Guthaben);
      writeln(ausf,'Legaler Auftrag');        {  legalen Auftrag setzen }
  		writeln(ausf,Schiff.Legal);
      writeln(ausf,'Geladen?');               {  Geladen? }
  		writeln(ausf,Schiff.LadLegal);
      writeln(ausf,'Illegaler Auftrag');      {  ilegalen Auftrag setzen }
  		writeln(ausf,Schiff.Illegal);
      writeln(ausf,'Geladen?');               {  Geladen? }
  		writeln(ausf,Schiff.LadIlleg);
      close(ausf);                            {  Datei schlieáen }
    end;                                      {E if: Datei vorhanden }
  end else begin                            {N Datei vorhanden }
    erg:=$ff;                               {  Fehler setzen }
  end;                                      {E if: Datei vorhanden }
  if BServerDa then begin                                                       //? Server B
    assign(ausf,BServerPath+'\Dat_'+inttostr(Schiff.Nr)+'.txt'); {  Handelsdatei schreiben }
    {$I-}
    rewrite(ausf);                            {  Auftragsdatei schreiben }
    {$I+}
    if IOResult = 0 then begin                {? Datei vorhanden }
      writeln(ausf,'Captain');                {  Captain setzen }
  		writeln(ausf,Schiff.Captain);
      writeln(ausf,'Raumschiff');             {  Raumschiff setzen }
  		writeln(ausf,Schiff.Typ);
      writeln(ausf,'Guthaben');               {  Guthaben setzen }
  		writeln(ausf,Schiff.Guthaben);
      writeln(ausf,'Legaler Auftrag');        {  legalen Auftrag setzen }
  		writeln(ausf,Schiff.Legal);
      writeln(ausf,'Geladen?');               {  Geladen? }
  		writeln(ausf,Schiff.LadLegal);
      writeln(ausf,'Illegaler Auftrag');      {  ilegalen Auftrag setzen }
  		writeln(ausf,Schiff.Illegal);
      writeln(ausf,'Geladen?');               {  Geladen? }
  		writeln(ausf,Schiff.LadIlleg);
      close(ausf);                            {  Datei schlieáen }

      assign(ausf,BServerPath+'\Log_'+inttostr(Schiff.Nr)+'.txt'); {  Handelsdatei schreiben }
      {$I-}
      append(ausf);                            {  Auftragsdatei schreiben }
      {$I+}
      if IOResult = 0 then begin                {? Datei vorhanden }
        writeln(ausf,'----- Sektor:' + inttostr(sektor) + ' ------');
        writeln(ausf,'Captain');                {  Captain setzen }
  			writeln(ausf,Schiff.Captain);
        writeln(ausf,'Raumschiff');             {  Raumschiff setzen }
  			writeln(ausf,Schiff.Typ);
        writeln(ausf,'Guthaben');               {  Guthaben setzen }
  			writeln(ausf,Schiff.Guthaben);
        writeln(ausf,'Legaler Auftrag');        {  legalen Auftrag setzen }
  			writeln(ausf,Schiff.Legal);
        writeln(ausf,'Geladen?');               {  Geladen? }
  			writeln(ausf,Schiff.LadLegal);
        writeln(ausf,'Illegaler Auftrag');      {  ilegalen Auftrag setzen }
  			writeln(ausf,Schiff.Illegal);
        writeln(ausf,'Geladen?');               {  Geladen? }
  			writeln(ausf,Schiff.LadIlleg);
        close(ausf);                            {  Datei schlieáen }
      end else begin                            {N Datei vorhanden }
        {$I-}
        rewrite(ausf);                            {  Auftragsdatei schreiben }
        {$I+}
        if IOResult = 0 then begin                {? Datei vorhanden }
          writeln(ausf,'----------------------');
          writeln(ausf,'Captain');                {  Captain setzen }
  				writeln(ausf,Schiff.Captain);
          writeln(ausf,'Raumschiff');             {  Raumschiff setzen }
  				writeln(ausf,Schiff.Typ);
          writeln(ausf,'Guthaben');               {  Guthaben setzen }
  				writeln(ausf,Schiff.Guthaben);
          writeln(ausf,'Legaler Auftrag');        {  legalen Auftrag setzen }
  				writeln(ausf,Schiff.Legal);
          writeln(ausf,'Geladen?');               {  Geladen? }
  				writeln(ausf,Schiff.LadLegal);
          writeln(ausf,'Illegaler Auftrag');      {  ilegalen Auftrag setzen }
  				writeln(ausf,Schiff.Illegal);
          writeln(ausf,'Geladen?');               {  Geladen? }
  				writeln(ausf,Schiff.LadIlleg);
          close(ausf);                            {  Datei schlieáen }
        end;                                      {E if: Datei vorhanden }
      end;                                      {E if: Datei vorhanden }
      //  Info erzeugen
      assign(ausf,BServerPath+'\info\Dat_'+inttostr(Schiff.Nr)+'.txt'); {  Handelsdatei schreiben }
      {$I-}
      rewrite(ausf);                            {  Auftragsdatei schreiben }
      {$I+}
      if IOResult = 0 then begin                {? Datei vorhanden }
        writeln(ausf,'Captain');                {  Captain setzen }
    		writeln(ausf,Schiff.Captain);
        writeln(ausf,'Raumschiff');             {  Raumschiff setzen }
    		writeln(ausf,Schiff.Typ);
        writeln(ausf,'Guthaben');               {  Guthaben setzen }
    		writeln(ausf,Schiff.Guthaben);
        writeln(ausf,'Legaler Auftrag');        {  legalen Auftrag setzen }
    		writeln(ausf,Schiff.Legal);
        writeln(ausf,'Geladen?');               {  Geladen? }
    		writeln(ausf,Schiff.LadLegal);
        writeln(ausf,'Illegaler Auftrag');      {  ilegalen Auftrag setzen }
    		writeln(ausf,Schiff.Illegal);
        writeln(ausf,'Geladen?');               {  Geladen? }
    		writeln(ausf,Schiff.LadIlleg);
        close(ausf);                            {  Datei schlieáen }
      end;                                      {E if: Datei vorhanden }
    end;                                      {E if: Datei vorhanden }
  end;
  datsc:=erg;
end;
//******************************************************************************
function datle : byte;                      {  Daten aus Datei lesen }
var
  egstr : string;
  erg : byte;                               { Ergebnis: 1 = OK; ff = Fehler }
begin
  erg:=1;                                   {  Noch kein Fehler }
  assign(einf,ServerPath+'\Dat_'+inttostr(Schiff.Nr)+'.txt'); {  Handelsdatei lesen }
  {$I-}
  reset(einf);                              {  Auftragsdatei ”ffnen }
  {$I+}
  if IOResult = 0 then begin                {? Datei vorhanden }
    readln(einf,egstr);                     {  Zeile 1 lesen }
    if (egstr = 'Captain') then begin       {? Captain }
      readln(einf,Schiff.Captain);          {  lesen }
    end else begin                          {N Captain}
      erg:=$ff;                             {  Fehler setzen }
    end;                                    {E if: Captain }
    readln(einf,egstr);                     {  Zeile esen }
    if (egstr = 'Raumschiff') then begin    {? Raumschiff }
      readln(einf,Schiff.Typ);              {  lesen }
    end else begin                          {N Raumschiff }
      erg:=$ff;                             {  Fehler setzen }
    end;                                    {E if: Raumschiff }
    readln(einf,egstr);                     {  Zeile esen }
    if (egstr = 'Guthaben') then begin      {? Guthaben }
      readln(einf,Schiff.Guthaben);         {  lesen }
    end else begin                          {N Guthaben}
      erg:=$ff;                             {  Fehler setzen }
    end;                                    {E if: Guthaben }
    readln(einf,egstr);                     {  Zeile esen }
    if (egstr = 'Legaler Auftrag') then begin    {? legaler Auftrag }
      readln(einf,Schiff.Legal);            {  lesen }
    end else begin                          {N legaler Auftrag}
      erg:=$ff;                             {  Fehler setzen }
    end;                                    {E if: legaler Auftrag }
    readln(einf,egstr);                     {  Zeile esen }
    if (egstr = 'Geladen?') then begin      {? Was geladen ? }
      readln(einf,Schiff.LadLegal);         {  lesen }
    end else begin                          {N Guthaben}
      erg:=$ff;                             {  Fehler setzen }
    end;                                    {E if: Guthaben }
    readln(einf,egstr);                     {  Zeile esen }
    if (egstr = 'Illegaler Auftrag') then begin    {? ilegaler Auftrag }
      readln(einf,Schiff.Illegal);          {  lesen }
    end else begin                          {N ilegaler Auftrag}
      erg:=$ff;                             {  Fehler setzen }
    end;                                    {E if: ilegaler Auftrag }
    readln(einf,egstr);                     {  Zeile esen }
    if (egstr = 'Geladen?') then begin      {? Was geladen ? }
      readln(einf,Schiff.LadIlleg);         {  lesen }
    end else begin                          {N Guthaben}
      erg:=$ff;                             {  Fehler setzen }
    end;                                    {E if: Guthaben }
    close(einf);                            {  Datei schlieáen }
  end else begin                            {N Datei vorhanden }
      erg:=$ff;                             {  Fehler setzen }
  end;                                      {E if: Datei vorhanden }
  datle:=erg;
end;
//******************************************************************************
function usrle : byte;                      {  Nutzernummer lesen }
var
  zws : string;
  erg : byte;                               { Ergebnis: 1 = OK; ff = Fehler }
  benutzer : byte;
begin
  erg:=$ff;                                 {  Fehler }
  assign(einf,DiskPath+'\usrnr.txt');       {  Benutzernummer lesen }
  {$I-}
  reset(einf);                              {  Auftragsdatei ”ffnen }
  {$I+}
  if IOResult = 0 then begin                {? Datei vorhanden }
    readln(einf,zws);                       {  Zeile 1 lesen }
    benutzer:=strtoint(zws);                {  Benutzer festlegen }
    if (benutzer > 0) and                   {? Benutzer im legalen Bereich }
       (benutzer <= 99) then begin
         Schiff.Nr:=benutzer;               {  Nutzer festlegen }
         erg:=1;                            {  Benutzer legal }
    end;
    close(einf);                            {  Datei schlieáen }
  end;                                      {E if: Datei vorhanden }
  usrle:=erg;                               {  Ergebnis melden }
end;
//******************************************************************************
procedure EreignLesen;                                                          //  Auftrag lesen
var
  egstr : string;
  nr    : word;
  zw    : word;
begin
  assign(einf,ServerPath+'\Ereign.dat');                                        //  Dateiname festlegen
  {$I-}
  reset(einf);                                                                  //  Auftragsdatei öffnen
  {$I+}
  if IOResult = 0 then begin                                                    //? Datei vorhanden
    nr:=1;                                                                      //  Bei Auftrag 1 beginnen
    Ereign_vb:=0;                                                               //  Noch kein Ereignis
    while not EOF(einf) do begin                                                //S ... bis Dateiende
      readln(einf,egstr);                                                       //  Eine Zeile lesen
      zw:=StrToIntDW(egstr);                                                    //  Zahl extrahieren
      if (zw = nr) then begin                                                   //? Richtiger Datensatz
        Ereign_vb:=nr;                                                          //  Ereignis gefunden
        readln(einf,egstr);                                                     //  Eine Zeile lesen
        Ereignis[nr].was := egstr;                                              //  Was ist passiert
        readln(einf,egstr);                                                     //  Eine Zeile lesen
        Ereignis[nr].defekt := egstr;                                           //  Was ist defekt
        readln(einf,egstr);                                                     //  Eine Zeile lesen
        Ereignis[nr].kosten := StrToIntDW(egstr);                               //  Was kostet es
        inc (nr);                                                               //  Ein Datensatz mehr
      end;                                                                      //E if: Richtiger Datensatz
    end;                                                                        //E S.: ... bis Dateiende
    close(einf);                            {  Datei schlieáen }
  end;                                      {E if: Datei vorhanden }
end;
//******************************************************************************
procedure AuftrLesen;                                                           //  Auftrag lesen
var
  egstr : string;
  nr    : word;
  zw    : word;
begin
  if (Sektor <= 4) then begin                                                   //? Legaler Sektor
    assign(einf,ServerPath+'\LA_AUFTR.dat');                                    //  Dateiname festlegen
    {$I-}
    reset(einf);                                                                //  Auftragsdatei öffnen
    {$I+}
    if IOResult = 0 then begin                                                  //? Datei vorhanden
      nr:=1;                                                                    //  Bei Auftrag 1 beginnen
      A_Auftr_vb:=0;                                                            //  Noch kein Auftrag
      while not EOF(einf) do begin                                              //S ... bis Dateiende
        readln(einf,egstr);                                                     //  Eine Zeile lesen
        zw:=StrToIntDW(egstr);                                                  //  Zahl extrahieren
        if (zw = nr) then begin                                                 //? Richtiger Datensatz
          A_Auftr_vb:=nr;                                                       //  Auftrag gefunden
          readln(einf,egstr);                                                   //  Eine Zeile lesen
          A_Auftr[nr].startsek := StrToIntDW(egstr);                            //  Startsektor
          readln(einf,egstr);                                                   //  Eine Zeile lesen
          A_Auftr[nr].zielsek := StrToIntDW(egstr);                             //  Zielsektor
          readln(einf,egstr);                                                   //  Eine Zeile lesen
          A_Auftr[nr].lohn := StrToIntDW(egstr);                                //  Lohn
          readln(einf,egstr);                                                   //  Eine Zeile lesen
          A_Auftr[nr].ladung := egstr;                                          //  Ladung
          readln(einf,egstr);                                                   //  Eine Zeile lesen
          A_Auftr[nr].startort := egstr;                                        //  Startort
          readln(einf,egstr);                                                   //  Eine Zeile lesen
          A_Auftr[nr].zielort := egstr;                                         //  Zielort
          inc (nr);                                                             //  Ein Datensatz mehr
        end;                                                                    //E if: Richtiger Datensatz
      end;                                                                      //E S.: ... bis Dateiende
      close(einf);                            {  Datei schlieáen }
    end;                                      {E if: Datei vorhanden }
  end else begin                                                                //N Legaler Sektor
    assign(einf,ServerPath+'\IA_AUFTR.dat');                                    //  Dateiname festlegen
    {$I-}
    reset(einf);                                                                //  Auftragsdatei öffnen
    {$I+}
    if IOResult = 0 then begin                                                  //? Datei vorhanden
      nr:=1;                                                                    //  Bei Auftrag 1 beginnen
      A_Auftr_vb:=0;                                                            //  Noch kein Auftrag
      while not EOF(einf) do begin                                              //S ... bis Dateiende
        readln(einf,egstr);                                                     //  Eine Zeile lesen
        zw:=StrToIntDW(egstr);                                                  //  Zahl extrahieren
        if (zw = nr) then begin                                                 //? Richtiger Datensatz
          A_Auftr_vb:=nr;                                                       //  Auftrag gefunden
          readln(einf,egstr);                                                   //  Eine Zeile lesen
          A_Auftr[nr].ladung := egstr;                                          //  Ladung
          readln(einf,egstr);                                                   //  Eine Zeile lesen
          A_Auftr[nr].startsek := StrToIntDW(egstr);                            //  Startsektor
          readln(einf,egstr);                                                   //  Eine Zeile lesen
          A_Auftr[nr].startort := egstr;                                        //  Startort
          readln(einf,egstr);                                                   //  Eine Zeile lesen
          A_Auftr[nr].zielsek := StrToIntDW(egstr);                             //  Zielsektor
          readln(einf,egstr);                                                   //  Eine Zeile lesen
          A_Auftr[nr].zielort := egstr;                                         //  Zielort
          readln(einf,egstr);                                                   //  Eine Zeile lesen
          A_Auftr[nr].lohn := StrToIntDW(egstr);                                //  Lohn
          inc (nr);                                                             //  Ein Datensatz mehr
        end;                                                                    //E if: Richtiger Datensatz
      end;                                                                      //E S.: ... bis Dateiende
      close(einf);                            {  Datei schlieáen }
    end;                                      {E if: Datei vorhanden }
  end;                                                                          //E if: Legaler Sektor
  if (Sektor <= 4) then begin                                                   //? Legaler Sektor
    assign(einf,ServerPath+'\LB_AUFTR.dat');                                    //  Dateiname festlegen
    {$I-}
    reset(einf);                                                                //  Auftragsdatei öffnen
    {$I+}
    if IOResult = 0 then begin                                                  //? Datei vorhanden
      nr:=1;                                                                    //  Bei Auftrag 1 beginnen
      B_Auftr_vb:=0;                                                            //  Noch kein Auftrag
      while not EOF(einf) do begin                                              //S ... bis Dateiende
        readln(einf,egstr);                                                     //  Eine Zeile lesen
        zw:=StrToIntDW(egstr);                                                  //  Zahl extrahieren
        if (zw = nr) then begin                                                 //? Richtiger Datensatz
          B_Auftr_vb:=nr;                                                       //  Auftrag gefunden
          readln(einf,egstr);                                                   //  Eine Zeile lesen
          B_Auftr[nr].startsek := StrToIntDW(egstr);                            //  Startsektor
          readln(einf,egstr);                                                   //  Eine Zeile lesen
          B_Auftr[nr].zielsek := StrToIntDW(egstr);                             //  Zielsektor
          readln(einf,egstr);                                                   //  Eine Zeile lesen
          B_Auftr[nr].lohn := StrToIntDW(egstr);                                //  Lohn
          readln(einf,egstr);                                                   //  Eine Zeile lesen
          B_Auftr[nr].ladung := egstr;                                          //  Ladung
          readln(einf,egstr);                                                   //  Eine Zeile lesen
          B_Auftr[nr].startort := egstr;                                        //  Startort
          readln(einf,egstr);                                                   //  Eine Zeile lesen
          B_Auftr[nr].zielort := egstr;                                         //  Zielort
          inc (nr);                                                             //  Ein Datensatz mehr
        end;                                                                    //E if: Richtiger Datensatz
      end;                                                                      //E S.: ... bis Dateiende
      close(einf);                            {  Datei schlieáen }
    end;                                      {E if: Datei vorhanden }
  end else begin                                                                //N Legaler Sektor
    assign(einf,ServerPath+'\IB_AUFTR.dat');                                    //  Dateiname festlegen
    {$I-}
    reset(einf);                                                                //  Auftragsdatei öffnen
    {$I+}
    if IOResult = 0 then begin                                                  //? Datei vorhanden
      nr:=1;                                                                    //  Bei Auftrag 1 beginnen
      B_Auftr_vb:=0;                                                            //  Noch kein Auftrag
      while not EOF(einf) do begin                                              //S ... bis Dateiende
        readln(einf,egstr);                                                     //  Eine Zeile lesen
        zw:=StrToIntDW(egstr);                                                  //  Zahl extrahieren
        if (zw = nr) then begin                                                 //? Richtiger Datensatz
          B_Auftr_vb:=nr;                                                       //  Auftrag gefunden
          readln(einf,egstr);                                                   //  Eine Zeile lesen
          B_Auftr[nr].ladung := egstr;                                          //  Ladung
          readln(einf,egstr);                                                   //  Eine Zeile lesen
          B_Auftr[nr].startsek := StrToIntDW(egstr);                            //  Startsektor
          readln(einf,egstr);                                                   //  Eine Zeile lesen
          B_Auftr[nr].startort := egstr;                                        //  Startort
          readln(einf,egstr);                                                   //  Eine Zeile lesen
          B_Auftr[nr].zielsek := StrToIntDW(egstr);                             //  Zielsektor
          readln(einf,egstr);                                                   //  Eine Zeile lesen
          B_Auftr[nr].zielort := egstr;                                         //  Zielort
          readln(einf,egstr);                                                   //  Eine Zeile lesen
          B_Auftr[nr].lohn := StrToIntDW(egstr);                                //  Lohn
          inc (nr);                                                             //  Ein Datensatz mehr
        end;                                                                    //E if: Richtiger Datensatz
      end;                                                                      //E S.: ... bis Dateiende
      close(einf);                            {  Datei schlieáen }
    end;                                      {E if: Datei vorhanden }
  end;                                                                          //E if: Legaler Sektor
  if (sektor >= 5) then begin                                                   //? Illegaler Sektor
    case sektor of                                                              //> Sektor
      5: begin
           assign(einf,ServerPath+'\CODESS5A.dat');                             //  Dateiname festlegen
         end;
      6: begin
           assign(einf,ServerPath+'\CODESS6A.dat');                             //  Dateiname festlegen
         end;
      7: begin
           assign(einf,ServerPath+'\CODESS7A.dat');                             //  Dateiname festlegen
         end;
    end;                                                                        //E case Sektor
    {$I-}
    reset(einf);                                                                //  Auftragsdatei öffnen
    {$I+}
    if IOResult = 0 then begin                                                  //? Datei vorhanden
      A_Code_vb:=0;                                                             //  Noch kein Code
      while not EOF(einf) do begin                                              //S ... bis Dateiende
	      inc(A_Code_vb);                                                         //  Ein Code mehr
        readln(einf,egstr);                                                     //  Eine Zeile lesen
		    A_Code[A_Code_vb]:=copy(egstr,1,4);                                     //  Code in das Feld
      end;                                                                      //E S.: ... bis Dateiende
      close(einf);                            {  Datei schlieáen }
    end;                                      {E if: Datei vorhanden }
    case sektor of                                                              //> Sektor
      5: begin
           assign(einf,ServerPath+'\CODESS5B.dat');                            //  Dateiname festlegen
         end;
      6: begin
           assign(einf,ServerPath+'\CODESS6B.dat');                            //  Dateiname festlegen
         end;
      7: begin
           assign(einf,ServerPath+'\CODESS7B.dat');                            //  Dateiname festlegen
         end;
    end;                                                                        //E case Sektor
    {$I-}
    reset(einf);                                                                //  Auftragsdatei öffnen
    {$I+}
    if IOResult = 0 then begin                                                  //? Datei vorhanden
      B_Code_vb:=0;                                                             //  Noch kein Code
      while not EOF(einf) do begin                                              //S ... bis Dateiende
	      inc(B_Code_vb);                                                         //  Ein Code mehr
        readln(einf,egstr);                                                     //  Eine Zeile lesen
		    B_Code[B_Code_vb]:=copy(egstr,1,4);                                     //  Code in das Feld
      end;                                                                      //E S.: ... bis Dateiende
      close(einf);                            {  Datei schlieáen }
    end;                                      {E if: Datei vorhanden }
  end else begin
    A_Code_vb:=0;
    B_Code_vb:=0;
  end;                                                                          //E if: Illegaler Sektro
  Form1.M_Info.Text:=AnsiToUTF8(IntToStr(A_Auftr_vb)+'  '+IntToStr(B_Auftr_vb)+'  '+IntToStr(A_Code_vb)+'  '+IntToStr(B_Code_vb));
end;
//******************************************************************************
procedure Bs_Update;
begin
  case Sektor of                                                                //> Sektor
  0: begin
       Form1.Image1.Picture.LoadFromFile(ServerPath+'\sektor0.bmp');
       Form1.L_Sektor.Caption:='Raumsektor';
     end;
  1: begin
       Form1.Image1.Picture.LoadFromFile(ServerPath+'\Sektor1.bmp');
       Form1.L_Sektor.Caption:='Raumsektor 1';
     end;
  2: begin
       Form1.Image1.Picture.LoadFromFile(ServerPath+'\Sektor2.bmp');
       Form1.L_Sektor.Caption:='Raumsektor 2';
     end;
  3: begin
       Form1.Image1.Picture.LoadFromFile(ServerPath+'\Sektor3.bmp');
       Form1.L_Sektor.Caption:='Raumsektor 3';
     end;
  4: begin
       Form1.Image1.Picture.LoadFromFile(ServerPath+'\Sektor4.bmp');
       Form1.L_Sektor.Caption:='Raumsektor 4';
     end;
  5: begin
       Form1.Image1.Picture.LoadFromFile(ServerPath+'\Sektor5.bmp');
       Form1.L_Sektor.Caption:='Raumsektor 5';
     end;
  6: begin
       Form1.Image1.Picture.LoadFromFile(ServerPath+'\Sektor6.bmp');
       Form1.L_Sektor.Caption:='Raumsektor 6';
     end;
  7: begin
       Form1.Image1.Picture.LoadFromFile(ServerPath+'\Sektor7.bmp');
       Form1.L_Sektor.Caption:='Raumsektor 7';
     end;
  end;
  Form1.Image1.Left:=0;
  Form1.Image1.Top:=0;
  if (Form1.Image1.Width > Form1.ClientWidth) then begin
    Form1.Image1.Width:=Form1.ClientWidth;
  end;
  if (Form1.Image1.Height > Form1.ClientHeight) then begin
    Form1.Image1.Height:=Form1.ClientHeight-100;
  end;
  if (Form1.ClientHeight > (Form1.Image1.Height + 2)) then begin
    Form1.Image1.Top:=(Form1.ClientHeight-Form1.Image1.Height) div 2;
  end;
  if (Form1.ClientWidth > (Form1.Image1.Width + 2)) then begin
    Form1.Image1.Left:=(Form1.ClientWidth-Form1.Image1.Width) div 2;
  end;
  if (Form1.ClientWidth > (Form1.L_Sektor.Width+2)) then begin
    Form1.L_Sektor.Left:=(Form1.ClientWidth-Form1.L_Sektor.Width) div 2;
  end;
  Form1.M_Info.Top:=Form1.ClientHeight-Form1.M_Info.Height;
  if (Form1.ClientWidth > (Form1.M_Info.Width+2)) then begin
    Form1.M_Info.Left:=(Form1.ClientWidth-Form1.M_Info.Width) div 2;
  end;
  Form1.M_Anz.Top:=Form1.ClientHeight-Form1.M_Anz.Height;
  Form1.M_Anz.Left:=760;
  Form1.P_Schiff.Top:=Form1.L_Sektor.Height+20;
  if (Form1.ClientWidth > (Form1.P_Schiff.Width+2)) then begin
    Form1.P_Schiff.Left:=(Form1.ClientWidth-Form1.P_Schiff.Width) div 2;
  end;
  Form1.P_Name.Visible:=false;
  Form1.P_Schiff.Visible:=false;
  Form1.P_Auftrag.Visible:=false;
  Form1.P_Auftrag.Top:=255;
  if (Form1.ClientWidth > (Form1.P_Auftrag.Width+2)) then begin
    Form1.P_Auftrag.Left:=(Form1.ClientWidth-Form1.P_Auftrag.Width) div 2;
  end;
  Form1.P_BeEntl.Visible:=false;
  Form1.P_BeEntl.Top:=255;
  if (Form1.ClientWidth > (Form1.P_BeEntl.Width+2)) then begin
    Form1.P_BeEntl.Left:=(Form1.ClientWidth-Form1.P_BeEntl.Width) div 2;
  end;
  Form1.P_Code.Visible:=false;
  Form1.P_Code.Top:=300;
  if (Form1.ClientWidth > (Form1.P_Code.Width+2)) then begin
    Form1.P_Code.Left:=(Form1.ClientWidth-Form1.P_Code.Width) div 2;
  end;
  Form1.Width:=800;
  Form1.Height:=600;
end;
//******************************************************************************
procedure IniLesen;                                                             //  Ini-Datei lesen
var
  egstr : string;
begin
  Sektor:=0;                                                                    //  Sektor wählbar
  DiskPath:='a:\';                                                              //  Pfad zur Disk auf Standart
  ServerPath:='d:\';                                                            //  Pfad zum Server auf Standart
  BServerDa:=false;
  assign(einf,ProgrammPath+'space.ini');                                        //  Dateiname festlegen
  {$I-}
  reset(einf);                              {  Auftragsdatei ”ffnen }
  {$I+}
  if IOResult = 0 then begin                {? Datei vorhanden }
    readln(einf,egstr);                     {  Zeile 1 lesen }
    if (egstr = 'Sektor') then begin        {? Sektor }
      readln(einf,Sektor);                  {  lesen }
      IniSektor:=Sektor;                    {  IniSektor setzen }
    end;                                    {E if: Disk }
    readln(einf,egstr);                     {  Zeile 1 lesen }
    if (egstr = 'Disk') then begin          {? Disk }
      readln(einf,DiskPath);                {  lesen }
    end;                                    {E if: Disk }
    readln(einf,egstr);                     {  Zeile 1 lesen }
    if (egstr = 'Server') then begin        {? Server }
      readln(einf,ServerPath);              {  lesen }
    end;                                    {E if: Server }
    readln(einf,egstr);                     {  Zeile 1 lesen }
    if (egstr = 'BServer') then begin       {? Server B }
      readln(einf,BServerPath);             {  lesen }
      BServerDa:=true;
    end;                                    {E if: Server B }
    close(einf);                            {  Datei schlieáen }
  end;                                      {E if: Datei vorhanden }
end;
//******************************************************************************
procedure SchiffAnz;
begin
  Form1.M_Schiff1.Clear;
  Form1.M_Schiff1.Lines.Add(AnsiToUTF8('Captain: '+Schiff.Captain));
  Form1.M_Schiff1.Lines.Add(AnsiToUTF8(''));
  Form1.M_Schiff1.Lines.Add(AnsiToUTF8('Raumschiff: Space Car '+Schiff.Typ));
  Form1.M_Schiff1.Lines.Add(AnsiToUTF8(''));
  Form1.M_Schiff1.Lines.Add(AnsiToUTF8('Credits: ' + inttostr(Schiff.Guthaben)));

  Form1.M_Schiff2.Clear;
  Form1.M_Schiff2.Lines.Add(AnsiToUTF8('Legaler Auftrag: ' + inttostr(Schiff.Legal)));
  Form1.M_Schiff2.Lines.Add(AnsiToUTF8('Geladen: ' +  Schiff.LadLegal));
  Form1.M_Schiff2.Lines.Add(AnsiToUTF8(''));
  Form1.M_Schiff2.Lines.Add(AnsiToUTF8('Illegaler Auftrag: ' + inttostr(Schiff.Illegal)));
  Form1.M_Schiff2.Lines.Add(AnsiToUTF8('Geladen: ' +  Schiff.LadIlleg));

  Form1.P_Schiff.Visible:=true;
end;
//******************************************************************************
function CodeAnz(init : boolean) : byte;
var
  i  : integer;
  nr : integer;
  erg : byte;
begin
  erg:=0;
  if (init) then begin
    Form1.E_Code.Text:=AnsiToUTF8('');
    //Form1.P_Code.Top:=300;
    //Form1.P_Code.Left:=200;
    Form1.P_Code.Visible:=true;
    Form1.E_Code.SetFocus;
    Form1.M_Info.Text:=AnsiToUTF8('');
    Form1.M_Info.Lines.Add(AnsiToUTF8('Bitte geben Sie den Code ein'));
  end else begin
    if (ord(bef) = 13) then begin                                    //? Cr
      if (schiff.typ = '1') then begin                                            //? Schiffstyp 1
        nr:=0;
        for i:=1 to A_Code_vb do begin                                            //S ... Für alle Codes
          if (Form1.E_Code.Text = A_Code[i]) then begin
            nr:=i;
          end;
        end;
        if (nr > 0) then begin
          if (ACodeUse[nr]) then begin
            nr:=0;
            erg:=$ff;
            ;
          end else begin
            W_Auftr[1].nr      := nr;                                                 //  Auftrag übertragen
            W_Auftr[1].startsek:= A_Auftr[nr].startsek;                               //  Auftrag übertragen
            W_Auftr[1].startort:= A_Auftr[nr].startort;
            W_Auftr[1].zielsek := A_Auftr[nr].zielsek;
            W_Auftr[1].zielort := A_Auftr[nr].zielort;
            W_Auftr[1].ladung  := A_Auftr[nr].ladung ;
            W_Auftr[1].lohn    := A_Auftr[nr].lohn;
            W_Aktiv:=1;
            W_Max:=1;
            erg:=1;
            ACodeUse[nr]:=true;
          end;
          AUseSchreiben;                                                         //  Datei schreiben
        end else begin
          erg:=$ff;
        end;
      end else begin                                                              //N Schiffstyp 1
        nr:=0;
        for i:=1 to B_Code_vb do begin                                            //S ... Für alle Codes
          if (Form1.E_Code.Text = B_Code[i]) then begin
            nr:=i;
          end;
        end;
        if (nr > 0) then begin
          if (BCodeUse[nr]) then begin
            nr:=0;
            erg:=$ff;
            ;
          end else begin
            W_Auftr[1].nr      := nr;                                                 //  Auftrag übertragen
            W_Auftr[1].startsek:= B_Auftr[nr].startsek;                               //  Auftrag übertragen
            W_Auftr[1].startort:= B_Auftr[nr].startort;
            W_Auftr[1].zielsek := B_Auftr[nr].zielsek;
            W_Auftr[1].zielort := B_Auftr[nr].zielort;
            W_Auftr[1].ladung  := B_Auftr[nr].ladung ;
            W_Auftr[1].lohn    := B_Auftr[nr].lohn;
            W_Aktiv:=1;
            W_Max:=1;
            erg:=1;
            BCodeUse[nr]:=true;
          end;
        end else begin
          erg:=$ff;
        end;
        BUseSchreiben;                                                         //  Datei schreiben
      end;
      Form1.P_Code.Visible:=false;
      if (erg = 1) then begin
        Form1.M_Auftrag.Text:=AnsiToUTF8('');
        Form1.M_Auftrag.Lines.Add(AnsiToUTF8(''));
        Form1.M_Auftrag.Lines.Add(AnsiToUTF8(''));
        Form1.M_Auftrag.Lines.Add(AnsiToUTF8('Auftrag '+IntToStr(W_Aktiv)+' von '+IntToStr(W_Max)));   //  Kopfzeile
        Form1.M_Auftrag.Lines.Add(AnsiToUTF8(''));
        Form1.M_Auftrag.Lines.Add(AnsiToUTF8('Nr.: ' + IntToStr(W_Auftr[W_Aktiv].nr)));
        Form1.M_Auftrag.Lines.Add(AnsiToUTF8(W_Auftr[W_Aktiv].Ladung));
        Form1.M_Auftrag.Lines.Add(AnsiToUTF8('Von ' + W_Auftr[W_Aktiv].Startort + ' in Sektor ' + IntToStr(W_Auftr[W_Aktiv].StartSek)));
        Form1.M_Auftrag.Lines.Add(AnsiToUTF8('Nach ' + W_Auftr[W_Aktiv].Zielort + ' in Sektor ' + IntToStr(W_Auftr[W_Aktiv].ZielSek)));
        Form1.M_Auftrag.Lines.Add(AnsiToUTF8(''));
        Form1.M_Auftrag.Lines.Add(AnsiToUTF8(IntToStr(W_Auftr[W_Aktiv].Lohn) + ' Credits'));
        Form1.L_Links.Caption:='!';                                                 //  gewählt
        Form1.L_Rechts.Caption:='!';
        Form1.P_Auftrag.visible:=true;
        Form1.M_Info.Text:=AnsiToUTF8('Bitte bestaetigen Sie den Auftrag');
        Form1.M_Info.Lines.Add(AnsiToUTF8('mit der Enter-Taste'));
      end;
    end;
  end;
  CodeAnz:=erg;
end;
//******************************************************************************
function Entladen(init : boolean) : byte;
var
  erg : byte;
  i   : integer;
begin
  if (init) then begin
    repeat                                  {S ... bis Auftrag gefunden }
      i:=random(Ereign_vb);                 {  Ereignis suchen }
    until(i > 0);                           {E S.: ... bis Auftrag }
    Ereig_akt:=i;                         {  Ereignis lesen }
    if (Sektor <= 4) then begin                                                   //? Legaler Sektor
      if (schiff.typ = '1') then begin                                            //? Schiffstyp 1
        if (A_Auftr[schiff.Legal].Zielsek = Sektor) then begin                    //? Im richtigen Sektor
          Form1.M_BeEntl.Text:=AnsiToUTF8('Willkommen in ' + A_Auftr[schiff.Legal].ZielOrt);
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8('Ihr Raumschiff wird gerade entladen'));
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8('Ihr Lohn betraegt ' + IntToStr(A_Auftr[schiff.Legal].Lohn) + ' Credits'));
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8(''));
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8(''));
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8('Ereignis: ' + Ereignis[Ereig_akt].was));
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8('Folgen  : ' + Ereignis[Ereig_akt].defekt));
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8('Kosten  : ' + IntToStr(Ereignis[Ereig_akt].kosten) + ' Credits'));
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8(''));
          i:=A_Auftr[schiff.Legal].Lohn - Ereignis[Ereig_Akt].kosten;
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8('Sie haben somit einen Verdienst von ' + IntToStr(i) + ' Credits'));
          ;
          Schiff.Guthaben:=Schiff.Guthaben+i;
          Schiff.Legal:=0;
          Schiff.LadLegal:='nein';
          Schiff.Illegal:=0;
          Schiff.LadIlleg:='nein';
          ;
          erg:=datsc;                                                                   //  Serverdatei schreiben
          if (erg = 1) then begin                                                       //? OK
            ;
          end else begin                                              //N OK
            Application.MessageBox('Netzwerkfehler: Mitarbeiter verstaendigen','',0);     //  Anzeige
            prgwo:=0;                                                 //  Ablauf von vorn
          end;                                                        //E if: ok
          ;
        end else begin                                                            //N Im richtigen Sektor
          if (schiff.Legal > 0) then begin
            Form1.M_BeEntl.Text:=AnsiToUTF8('Bitte fliegen Sie zum Entladen nach ' + A_Auftr[schiff.Legal].Zielort);
            Form1.M_BeEntl.Lines.Add(AnsiToUTF8('im Sektor ' + IntToStr(A_Auftr[schiff.Legal].Zielsek)));
          end else begin
            Form1.M_BeEntl.Text:=AnsiToUTF8('Bitte fliegen Sie zum Entladen');
            Form1.M_BeEntl.Lines.Add(AnsiToUTF8('zu einem illegalen Sektor'));
          end;
          erg:=1;                                                                       //  Ok
        end;                                                                      //E if: Im richtigen Sektor
      end else begin                                                              //N Schiffstyp 1
        if (B_Auftr[schiff.Legal].Zielsek = Sektor) then begin                    //? Im richtigen Sektor
          Form1.M_BeEntl.Text:=AnsiToUTF8('Willkommen in ' + B_Auftr[schiff.Legal].ZielOrt);
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8('Ihr Raumschiff wird gerade entladen'));
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8('Ihr Lohn betraegt ' + IntToStr(B_Auftr[schiff.Legal].Lohn) + ' Credits'));
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8(''));
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8(''));
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8('Ereignis: ' + Ereignis[Ereig_akt].was));
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8('Folgen  : ' + Ereignis[Ereig_akt].defekt));
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8('Kosten  : ' + IntToStr(Ereignis[Ereig_akt].kosten) + ' Credits'));
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8(''));
          i:=B_Auftr[schiff.Legal].Lohn - Ereignis[Ereig_Akt].kosten;
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8('Sie haben somit einen Verdienst von ' + IntToStr(i) + ' Credits'));
          ;
          Schiff.Guthaben:=Schiff.Guthaben+i;
          Schiff.Legal:=0;
          Schiff.LadLegal:='nein';
          Schiff.Illegal:=0;
          Schiff.LadIlleg:='nein';
          ;
          erg:=datsc;                                                                   //  Serverdatei schreiben
          if (erg = 1) then begin                                                       //? OK
            ;
          end else begin                                              //N OK
            Application.MessageBox('Netzwerkfehler: Mitarbeiter verstaendigen','',0);     //  Anzeige
            prgwo:=0;                                                 //  Ablauf von vorn
          end;                                                        //E if: ok
          ;
        end else begin                                                            //N Im richtigen Sektor
          if (schiff.Legal > 0) then begin
            Form1.M_BeEntl.Text:=AnsiToUTF8('Bitte fliegen Sie zum Entladen nach ' + B_Auftr[schiff.Legal].Zielort);
            Form1.M_BeEntl.Lines.Add(AnsiToUTF8('im Sektor ' + IntToStr(B_Auftr[schiff.Legal].Zielsek)));
          end else begin
            Form1.M_BeEntl.Text:=AnsiToUTF8('Bitte fliegen Sie zum Entladen');
            Form1.M_BeEntl.Lines.Add(AnsiToUTF8('zu einem illegalen Sektor'));
          end;
          erg:=1;                                                                       //  Ok
        end;                                                                      //E if: Im richtigen Sektor
      end;
    end else begin                                                                //N Legaler Sektor
      if (schiff.typ = '1') then begin                                            //? Schiffstyp 1
        if (A_Auftr[schiff.Illegal].Zielsek = Sektor) then begin                    //? Im richtigen Sektor
          Form1.M_BeEntl.Text:=AnsiToUTF8('Willkommen in ' + A_Auftr[schiff.Illegal].ZielOrt);
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8('Ihr Raumschiff wird gerade entladen'));
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8('Ihr Lohn betraegt ' + IntToStr(A_Auftr[schiff.Illegal].Lohn) + ' Credits'));
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8(''));
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8(''));
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8('Ereignis: ' + Ereignis[Ereig_akt].was));
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8('Folgen  : ' + Ereignis[Ereig_akt].defekt));
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8('Kosten  : ' + IntToStr(Ereignis[Ereig_akt].kosten) + ' Credits'));
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8(''));
          i:=A_Auftr[schiff.Illegal].Lohn - Ereignis[Ereig_Akt].kosten;
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8('Sie haben somit einen Verdienst von ' + IntToStr(i) + ' Credits'));
          ;
          Schiff.Guthaben:=Schiff.Guthaben+i;
          Schiff.Legal:=0;
          Schiff.ladLegal:='nein';
          Schiff.Illegal:=0;
          Schiff.LadIlleg:='nein';
          ;
          erg:=datsc;                                                                   //  Serverdatei schreiben
          if (erg = 1) then begin                                                       //? OK
            ;
          end else begin                                              //N OK
            Application.MessageBox('Netzwerkfehler: Mitarbeiter verstaendigen','',0);     //  Anzeige
            prgwo:=0;                                                 //  Ablauf von vorn
          end;                                                        //E if: ok
          ;
        end else begin                                                            //N Im richtigen Sektor
          if (schiff.Illegal > 0) then begin
            Form1.M_BeEntl.Text:=AnsiToUTF8('Bitte fliegen Sie zum Entladen nach ' + A_Auftr[schiff.Illegal].Zielort);
            Form1.M_BeEntl.Lines.Add(AnsiToUTF8('im Sektor ' + IntToStr(A_Auftr[schiff.Illegal].Zielsek)));
          end else begin
            Form1.M_BeEntl.Text:=AnsiToUTF8('Bitte fliegen Sie zum Entladen');
            Form1.M_BeEntl.Lines.Add(AnsiToUTF8('zu einem legalen Sektor'));
          end;
          erg:=1;                                                                       //  Ok
        end;                                                                      //E if: Im richtigen Sektor
      end else begin                                                              //N Schiffstyp 1
        if (B_Auftr[schiff.Illegal].Zielsek = Sektor) then begin                    //? Im richtigen Sektor
          Form1.M_BeEntl.Text:=AnsiToUTF8('Willkommen in ' + B_Auftr[schiff.Illegal].ZielOrt);
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8('Ihr Raumschiff wird gerade entladen'));
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8('Ihr Lohn betraegt ' + IntToStr(B_Auftr[schiff.Illegal].Lohn) + ' Credits'));
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8(''));
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8(''));
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8('Ereignis: ' + Ereignis[Ereig_akt].was));
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8('Folgen  : ' + Ereignis[Ereig_akt].defekt));
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8('Kosten  : ' + IntToStr(Ereignis[Ereig_akt].kosten) + ' Credits'));
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8(''));
          i:=B_Auftr[schiff.Illegal].Lohn - Ereignis[Ereig_Akt].kosten;
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8('Sie haben somit einen Verdienst von ' + IntToStr(i) + ' Credits'));
          ;
          Schiff.Guthaben:=Schiff.Guthaben+i;
          Schiff.Legal:=0;
          Schiff.Ladlegal:='nein';
          Schiff.Illegal:=0;
          Schiff.LadIlleg:='nein';
          ;
          erg:=datsc;                                                                   //  Serverdatei schreiben
          if (erg = 1) then begin                                                       //? OK
            ;
          end else begin                                              //N OK
            Application.MessageBox('Netzwerkfehler: Mitarbeiter verstaendigen','',0);     //  Anzeige
            prgwo:=0;                                                 //  Ablauf von vorn
          end;                                                        //E if: ok
          ;
        end else begin                                                            //N Im richtigen Sektor
          if (schiff.Illegal > 0) then begin
            Form1.M_BeEntl.Text:=AnsiToUTF8('Bitte fliegen Sie zum Entladen nach ' + B_Auftr[schiff.Illegal].Zielort);
            Form1.M_BeEntl.Lines.Add(AnsiToUTF8('im Sektor ' + IntToStr(B_Auftr[schiff.Illegal].Zielsek)));
          end else begin
            Form1.M_BeEntl.Text:=AnsiToUTF8('Bitte fliegen Sie zum Entladen');
            Form1.M_BeEntl.Lines.Add(AnsiToUTF8('zu einem legalen Sektor'));
          end;
          erg:=1;                                                                       //  Ok
        end;                                                                      //E if: Im richtigen Sektor
      end;                                                                        //E if: Schiffstyp 1
    end;                                                                          //E if: Legaler Sektor
    Form1.M_Info.Text:=AnsiToUTF8('');
    Form1.M_Info.Lines.Add(AnsiToUTF8(''));
    Form1.M_Info.Lines.Add(AnsiToUTF8('         xxxxxxxxxxxxx               Taste...'));
    Form1.P_BeEntl.Visible:=true;
    Schiffanz;
  end else begin
    erg:=1;                                                                       //  Ok
  end;
  Entladen:=erg;
end;
//******************************************************************************
function beladen(init : boolean) : byte;
var
  erg : byte;
begin
  if (init) then begin
  if (Sektor <= 4) then begin                                                   //? Legaler Sektor
    if (schiff.typ = '1') then begin                                            //? Schiffstyp 1
      if (A_Auftr[schiff.Legal].startsek = Sektor) then begin                   //? Im richtigen Sektor
        Form1.M_BeEntl.Text:=AnsiToUTF8('');
        Form1.M_BeEntl.Lines.Add(AnsiToUTF8('Ihr Schiff wurde gerade mit'));
        Form1.M_BeEntl.Lines.Add(AnsiToUTF8(''));
        Form1.M_BeEntl.Lines.Add(AnsiToUTF8(A_Auftr[schiff.Legal].ladung));
        Form1.M_BeEntl.Lines.Add(AnsiToUTF8(''));
        Form1.M_BeEntl.Lines.Add(AnsiToUTF8('beladen.'));
        Form1.M_BeEntl.Lines.Add(AnsiToUTF8(''));
        Form1.M_BeEntl.Lines.Add(AnsiToUTF8('Fliegen Sie bitte zum Entladen nach'));
        Form1.M_BeEntl.Lines.Add(AnsiToUTF8(A_Auftr[schiff.Legal].zielort + ' im Sektor ' + IntToStr(A_Auftr[schiff.Legal].zielsek)));
        ;
        Schiff.LadLegal:='ja';
        ;
        erg:=datsc;                                                                   //  Serverdatei schreiben
        if (erg = 1) then begin                                                       //? OK
          ;
        end else begin                                              //N OK
          Application.MessageBox('Netzwerkfehler: Mitarbeiter verstaendigen','',0);     //  Anzeige
          prgwo:=0;                                                 //  Ablauf von vorn
        end;                                                        //E if: ok
        ;
      end else begin                                                            //N Im richtigen Sektor
        if (schiff.Legal > 0) then begin
          Form1.M_BeEntl.Text:=AnsiToUTF8('Bitte fliegen Sie zum Beladen nach ' + A_Auftr[schiff.Legal].startort);
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8('im Sektor ' + IntToStr(A_Auftr[schiff.Legal].startsek)));
        end else begin
          Form1.M_BeEntl.Text:=AnsiToUTF8('Bitte fliegen Sie zum Beladen');
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8('zu einem illegalen Sektor'));
        end;
        erg:=1;                                                                       //  Ok
      end;                                                                      //E if: Im richtigen Sektor
    end else begin                                                              //N Schiffstyp 1
      if (B_Auftr[schiff.Legal].startsek = Sektor) then begin                   //? Im richtigen Sektor
        Form1.M_BeEntl.Text:=AnsiToUTF8('Ihr Schiff wurde gerade mit');
        Form1.M_BeEntl.Lines.Add(AnsiToUTF8(''));
        Form1.M_BeEntl.Lines.Add(AnsiToUTF8(''));
        Form1.M_BeEntl.Lines.Add(AnsiToUTF8(B_Auftr[schiff.Legal].ladung));
        Form1.M_BeEntl.Lines.Add(AnsiToUTF8('beladen.'));
        Form1.M_BeEntl.Lines.Add(AnsiToUTF8('Fliegen Sie bitte zum Entladen nach'));
        Form1.M_BeEntl.Lines.Add(AnsiToUTF8(B_Auftr[schiff.Legal].zielort + ' im Sektor ' + IntToStr(B_Auftr[schiff.Legal].zielsek)));
        ;
        Schiff.LadLegal:='ja';
        ;
        erg:=datsc;                                                                   //  Serverdatei schreiben
        if (erg = 1) then begin                                                       //? OK
          ;
        end else begin                                              //N OK
          Application.MessageBox('Netzwerkfehler: Mitarbeiter verstaendigen','',0);     //  Anzeige
          prgwo:=0;                                                 //  Ablauf von vorn
          erg:=0;
        end;                                                        //E if: ok
        ;
      end else begin                                                            //N Im richtigen Sektor
        if (schiff.Legal > 0) then begin
          Form1.M_BeEntl.Text:=AnsiToUTF8('Bitte fliegen Sie zum Beladen nach ' + B_Auftr[schiff.Legal].startort);
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8('im Sektor ' + IntToStr(B_Auftr[schiff.Legal].startsek)));
        end else begin
          Form1.M_BeEntl.Text:=AnsiToUTF8('Bitte fliegen Sie zum Beladen');
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8('zu einem illegalen Sektor'));
        end;
        erg:=1;                                                                       //  Ok
      end;                                                                      //E if: Im richtigen Sektor
    end;                                                                        //E if: Schiffstyp 1
  end else begin                                                                //N Legaler Sektor
    if (schiff.typ = '1') then begin                                            //? Schiffstyp 1
      if (A_Auftr[schiff.Illegal].startsek = Sektor) then begin                   //? Im richtigen Sektor
        Form1.M_BeEntl.Text:=AnsiToUTF8('Ihr Schiff wurde gerade mit');
        Form1.M_BeEntl.Lines.Add(AnsiToUTF8(''));
        Form1.M_BeEntl.Lines.Add(AnsiToUTF8(''));
        Form1.M_BeEntl.Lines.Add(AnsiToUTF8(A_Auftr[schiff.Illegal].ladung));
        Form1.M_BeEntl.Lines.Add(AnsiToUTF8('beladen.'));
        Form1.M_BeEntl.Lines.Add(AnsiToUTF8('Fliegen Sie bitte zum Entladen nach'));
        Form1.M_BeEntl.Lines.Add(AnsiToUTF8(A_Auftr[schiff.Illegal].zielort + ' im Sektor ' + IntToStr(A_Auftr[schiff.Illegal].zielsek)));
        ;
        Schiff.LadIlleg:='ja';
        ;
        erg:=datsc;                                                                   //  Serverdatei schreiben
        if (erg = 1) then begin                                                       //? OK
          ;
        end else begin                                              //N OK
          Application.MessageBox('Netzwerkfehler: Mitarbeiter verstaendigen','',0);     //  Anzeige
          prgwo:=0;                                                 //  Ablauf von vorn
          erg:=0;
        end;                                                        //E if: ok
        ;
      end else begin                                                            //N Im richtigen Sektor
        if (schiff.Illegal > 0) then begin
          Form1.M_BeEntl.Text:=AnsiToUTF8('Bitte fliegen Sie zum Beladen nach ' + A_Auftr[schiff.Illegal].startort);
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8('im Sektor ' + IntToStr(A_Auftr[schiff.Illegal].startsek)));
        end else begin
          Form1.M_BeEntl.Text:=AnsiToUTF8('Bitte fliegen Sie zum Beladen');
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8('zu einem legalen Sektor'));
        end;
        erg:=1;                                                                       //  Ok
      end;                                                                      //E if: Im richtigen Sektor
    end else begin                                                              //N Schiffstyp 1
      if (B_Auftr[schiff.Illegal].startsek = Sektor) then begin                   //? Im richtigen Sektor
        Form1.M_BeEntl.Text:=AnsiToUTF8('Ihr Schiff wurde gerade mit');
        Form1.M_BeEntl.Lines.Add(AnsiToUTF8(''));
        Form1.M_BeEntl.Lines.Add(AnsiToUTF8(''));
        Form1.M_BeEntl.Lines.Add(AnsiToUTF8(B_Auftr[schiff.Illegal].ladung));
        Form1.M_BeEntl.Lines.Add(AnsiToUTF8('beladen.'));
        Form1.M_BeEntl.Lines.Add(AnsiToUTF8('Fliegen Sie bitte zum Entladen nach'));
        Form1.M_BeEntl.Lines.Add(AnsiToUTF8(B_Auftr[schiff.Illegal].zielort + ' im Sektor ' + IntToStr(B_Auftr[schiff.Illegal].zielsek)));
        ;
        Schiff.LadIlleg:='ja';
        ;
        erg:=datsc;                                                                   //  Serverdatei schreiben
        if (erg = 1) then begin                                                       //? OK
          ;
        end else begin                                              //N OK
          Application.MessageBox('Netzwerkfehler: Mitarbeiter verstaendigen','',0);     //  Anzeige
          prgwo:=0;                                                 //  Ablauf von vorn
          erg:=0;
        end;                                                        //E if: ok
        ;
      end else begin                                                            //N Im richtigen Sektor
        if (schiff.Illegal > 0) then begin
          Form1.M_BeEntl.Text:=AnsiToUTF8('Bitte fliegen Sie zum Beladen nach ' + B_Auftr[schiff.Illegal].startort);
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8('im Sektor ' + IntToStr(B_Auftr[schiff.Illegal].startsek)));
        end else begin
          Form1.M_BeEntl.Text:=AnsiToUTF8('Bitte fliegen Sie zum Beladen');
          Form1.M_BeEntl.Lines.Add(AnsiToUTF8('zu einem legalen Sektor'));
        end;
        erg:=1;                                                                       //  Ok
      end;                                                                      //E if: Im richtigen Sektor
    end;                                                                        //E if: Schiffstyp 1
  end;                                                                          //E if: Legaler Sektor
  Form1.M_Info.Text:=AnsiToUTF8('');
  Form1.M_Info.Lines.Add(AnsiToUTF8(''));
  Form1.M_Info.Lines.Add(AnsiToUTF8('                              ... bitte Taste'));
  Form1.P_BeEntl.Visible:=true;
  Schiffanz;
  end else begin
    erg:=1;                                                                       //  Ok
  end;
  beladen:=erg;
end;
//******************************************************************************
procedure AuftrSchr;
var
  erg : byte;
begin
  if (Sektor <= 4) then begin                                                   //? Legaler Sektor
    Schiff.Legal:=W_Auftr[W_Aktiv].nr;                                          //  Beladen
    Schiff.LadLegal:='nein';
    Schiff.Illegal:=0;                                                          //  Kein Illegaler Auftrag
    Schiff.LadIlleg:='nein';
  end else begin                                                                //N Legaler Sektor
    Schiff.Illegal:=W_Auftr[W_Aktiv].nr;                                         //  Beladen
    Schiff.LadIlleg:='nein';
    Schiff.Legal:=0;                                                            //  Kein legaler Auftrag
    Schiff.LadLegal:='nein';
  end;                                                                          //E if: Legaler Sektor
  erg:=datsc;                                                                   //  Serverdatei schreiben
  if (erg = 1) then begin                                                       //? OK
    Form1.M_Info.Text:=AnsiToUTF8('Gute Reise zum Sektor');
  end else begin                                              //N OK
    Application.MessageBox('Netzwerkfehler: Mitarbeiter verstaendigen','',0);     //  Anzeige
  end;                                                        //E if: ok
end;
//******************************************************************************
procedure PrgPathLesen;
var  i,j:integer;
begin
     i := 0;                                                                    //  Anfang Programmname = 0
     ProgrammPath := ParamStr(0);                                               //  Pfad der programm EXE ermitteln
     for j := 1 to length(ProgrammPath) do begin                                //S Für alle Zeichen des Aufrufstrings
       if ProgrammPath[j] = '\' then begin                                      //? Anfang Dateiname
          i := j;                                                               //  Position im String merken
        end;                                                                    //E Anfang Dateiname
     end;                                                                       //E S.: Für alle Zeichen des Aufrufstrings
     ProgrammPath := copy(ProgrammPath,1,i);                                    //  Pfad ermitteln
end;
//******************************************************************************
procedure SetSektor(egSektor : integer);
begin
  case egSektor of
    1: begin
         if IniSektor = 0 then begin                                            {? Žndern m”glich }
           sektor:=1;                                                           {  Sektor 1 }
           Form1.L_Sektor.Caption:='Raumsektor 1';
         end;                                                                   {E if: Žndern m”glich }
       end;
    2: begin
         if IniSektor = 0 then begin                                            {? Žndern m”glich }
           sektor:=2;                                                           {  Sektor 1 }
           Form1.L_Sektor.Caption:='Raumsektor 2';
         end;                                                                   {E if: Žndern m”glich }
       end;
    3: begin
         if IniSektor = 0 then begin                                            {? Žndern m”glich }
           sektor:=3;                                                           {  Sektor 1 }
           Form1.L_Sektor.Caption:='Raumsektor 3';
         end;                                                                   {E if: Žndern m”glich }
       end;
    4: begin
         if IniSektor = 0 then begin                                            {? Žndern m”glich }
           sektor:=4;                                                           {  Sektor 1 }
           Form1.L_Sektor.Caption:='Raumsektor 4';
         end;                                                                   {E if: Žndern m”glich }
       end;
    5: begin
         if IniSektor = 0 then begin                                            {? Žndern m”glich }
           sektor:=5;                                                           {  Sektor 1 }
           UseLesen;
           Form1.L_Sektor.Caption:='Raumsektor 5';
         end;                                                                   {E if: Žndern m”glich }
       end;
    6: begin
         if IniSektor = 0 then begin                                            {? Žndern m”glich }
           sektor:=6;                                                           {  Sektor 1 }
           UseLesen;
           Form1.L_Sektor.Caption:='Raumsektor 6';
         end;                                                                   {E if: Žndern m”glich }
       end;
    7: begin
         if IniSektor = 0 then begin                                            {? Žndern m”glich }
           sektor:=7;                                                           {  Sektor 1 }
           UseLesen;
           Form1.L_Sektor.Caption:='Raumsektor 7';
         end;                                                                   {E if: Žndern m”glich }
       end;
  end;
  AuftrLesen;
  Bs_Update;
end;
//******************************************************************************
procedure Tastenaw(Key : Word);
var
  erg : byte;
  // $0d = Enter
  // $25 = Pfeil rechts
  // $26 = Pfeil auf
  // $27 = Pfeil links
  // $28 = Pfeil ab
  // $70 = F1
  // $71 = F2
  // $72 = F3
  // $73 = F4
  // $74 = F5
  // $75 = F6
  // $76 = F7
  // $77 = F8
  // $78 = F9
  // $79 = F10
begin
  case key of                                                                   //> Taste
    $1b: begin                                                                  //C ESC
           prgwo:=0;                                                            //  Anfang Programm
           Bs_Update;                                                           //  Bildschirm-Update
           Form1.M_Info.Text:=AnsiToUTF8('Bitte identifizieren Sie sich');
           Form1.M_Info.Lines.Add(AnsiToUTF8('                                 1.. Taste'));
         end;
    $0c: begin                                                                  //C ?
         end;
    // $25: begin                                                                  //C Pfeil links
    //     end;
    // $26: begin                                                                  //C Pfeil auf
    //     end;
    // $27: begin                                                                  //C Pfeil rechts
    //     end;
    // $28: begin                                                                  //C Pfeil abw.
    //     end;
    $70: begin                                                                  //C F1
           SetSektor(1);                                                        //  Sektor setzen
         end;
    $71: begin                                                                  //C F2
           SetSektor(2);                                                        //  Sektor setzen
         end;
    $72: begin                                                                  //C F3
           SetSektor(3);                                                        //  Sektor setzen
         end;
    $73: begin                                                                  //C F4
           SetSektor(4);                                                        //  Sektor setzen
         end;
    $74: begin                                                                  //C F5
           SetSektor(5);                                                        //  Sektor setzen
         end;
    $75: begin                                                                  //C F6
           SetSektor(6);                                                        //  Sektor setzen
         end;
    $76: begin                                                                  //C F7
           SetSektor(7);                                                        //  Sektor setzen
         end;
    $77: begin                                                                  //C F8
         end;
    $78: begin                                                                  //C F9
         end;
    $79: begin                                                                  //C F10
         end;
    else begin
       bef:=char(key);
       if (key >= $30) and (key <= $39) then begin                              //? Nummer
         rfid:=rfid+bef;
         if (length(rfid) > 10) then begin
           rfid:=copy(rfid,2,11);
         end;
       end else begin                                                         //N Nummer
         if (key >= 13) and (key <= ord('z'))  then begin                     //? Tastertureingabe
           case prgwo of                                                      //> Ablauf
           $00: begin                                                         //C Diskette lesen
                  form1.m_Anz.Text:=AnsiToUTF8('');                           //  Memo löschen
                  form1.M_Anz.SetFocus;                                       //  Tasteneingaben hierher
                  if (length(rfid) = 10) then begin
                    erg:=1;
                    Schiff.Nr:=StrToInt(rfid);
                    rfid:='';                                                 //  Neuer Chip notwendig
                  end else begin
                    erg:=0;
                  end;
                  //erg:=usrle;                                                 //  Benutzer lesen
                  if (erg = 1) then begin                                     //? OK
                    erg:=datle;                                                 //  Serverdatei lesen
                    if (erg = 1) then begin                                     //? OK
                      Schiffanz;                                              //  Schiff anzeigen
                      if (Schiff.Legal>0) or (Schiff.Illegal>0) then begin    //? Auftrag vorhanden
                        if (Schiff.LadLegal = 'ja')                           //? Schiff beladen
                        or (Schiff.LadIlleg = 'ja') then begin
                          erg:=Entladen(true);                              //  Entladen
                          prgwo:=$40;
                        end else begin                                        //N Schiff beladen
                          erg:=Beladen(true);                                 //  Beladen
                          prgwo:=$30;
                        end;
                      end else begin                                          //N Auftrag vorhanden
                        if (sektor <= 4) then begin                           //? Legaler Sektor
                          AuftrSuchen;                                        //  Aufträge
                          erg:=AuftrAnz(true);                                //  Aufträge anzeigen
                          prgwo:=$10;                                         //  Auftrag wählen
                        end else begin
                          erg:=CodeAnz(true);                                 //  Codeabfrage anzeigen
                          prgwo:=$20;                                         //  Codeeingabe
                        end;
                      end;
                    end else begin                                              //N OK
                      inc(prgwo);                                               //  Ablauf weiter
                      Form1.E_Name.Text:=AnsiToUTF8('');
                      Form1.P_Name.Top:=200;
                      Form1.P_Name.Left:=200;
                      Form1.P_Name.Visible:=true;
                      Form1.E_Name.SetFocus;
                    end;                                                        //E if: ok
                  end;                                                        //E if: OK
                end;
           $01: begin                                                         //C Captain abfragen
                  if (key = 13) then begin                                    //? Cr
                    if (length(Form1.E_Name.Text) = 0) then begin             //? Noch kein Name
                      Form1.E_Name.Text:=AnsiToUTF8('');
                      Form1.P_Name.Visible:=true;
                      Form1.E_Name.SetFocus;
                    end else begin                                            //N Noch kein Name
                      if length(Form1.E_Name.Text) > 40 then begin            //? Text zu lang
                        Form1.E_Name.Text:=AnsiToUTF8(copy(Form1.E_Name.Text,1,39));      //  Text begrenzen
                      end;                                                    //E if: Text zu lang
                      Schiff.Captain:=Form1.E_Name.Text;                      //  Captain festlegen
                      Schiff.Typ:='1';                                        //  Neues Schiff erzeugen
                      Schiff.Guthaben:=100000;
                      Schiff.Legal:=0;
                      Schiff.LadLegal:='nein';
                      Schiff.Illegal:=0;
                      Schiff.LadIlleg:='nein';
                      inc(prgwo);                                             //  Ablauf weiter
                      form1.m_Anz.Text:=AnsiToUTF8('1');                                  //  Memo löschen
                      form1.M_Anz.SetFocus;                                   //  Tasteneingaben hierher
                      Form1.P_Name.Visible:=false;
                      erg:=datsc;                                             //  Serverdatei lesen
                      if (erg = 1) then begin                                 //? OK
                        Schiffanz;                                            //  Schiff anzeigen
                        if (Schiff.Legal>0) or (Schiff.Illegal>0) then begin    //? Auftrag vorhanden
                          if (Schiff.LadLegal = 'ja')                           //? Schiff beladen
                          or (Schiff.LadIlleg = 'ja') then begin
                            erg:=Entladen(true);                              //  Entladen
                            prgwo:=$40;
                          end else begin                                        //N Schiff beladen
                            erg:=Beladen(true);                                 //  Beladen
                            prgwo:=$30;
                          end;
                        end else begin                                          //N Auftrag vorhanden
                          if (sektor <= 4) then begin                           //? Legaler Sektor
                            AuftrSuchen;                                        //  Aufträge
                            erg:=AuftrAnz(true);                                //  Aufträge anzeigen
                            prgwo:=$10;                                         //  Auftrag wählen
                          end else begin
                            erg:=CodeAnz(true);                                 //  Codeabfrage anzeigen
                            prgwo:=$20;                                         //  Codeeingabe
                          end;
                        end;
                      end else begin                                              //N OK
                        Application.MessageBox('Netzwerkfehler: Mitarbeiter verstaendigen','',0);     //  Anzeige
                        prgwo:=0;                                                 //  Ablauf von vorn
                      end;                                                        //E if: ok
                    end;                                                      //E if: Noch kein Name
                  end;                                                        //E if: Cr
                end;
           $10: begin                                                         //C Legalen Auftrag suchen
                  erg:=Auftranz(false);
                  if (erg > 0) then begin                                     //? Auftrag gewählt
                    AuftrSchr;                                                //  Schiff beladen
                    prgwo:=0;                                                            //  Anfang Programm
                    Bs_Update;                                                           //  Bildschirm-Update
                    Form1.M_Info.Text:=AnsiToUTF8('Bitte identifizieren Sie sich');
                    Form1.M_Info.Lines.Add(AnsiToUTF8('                               ... Ausweis'));
                  end;
                end;
           $20: begin                                                         //C Illegalen Auftrag suchen
                  erg:=CodeAnz(false);
                  if (erg = 1) then begin                                     //? Auftrag gewählt
                    inc(prgwo);
                  end else begin
                    if (erg = $ff) then begin
                      prgwo:=0;                                                            //  Anfang Programm
                      Bs_Update;                                                           //  Bildschirm-Update
                      Form1.M_Info.Text:=AnsiToUTF8('Bitte identifizieren Sie sich');
                      Form1.M_Info.Lines.Add(AnsiToUTF8('                                 3.. Taste'));
                    end;
                  end;
                end;
           $21: begin                                                         //C Illegalen Auftrag suchen
                  if key = 13 then begin
                    AuftrSchr;                                                //  Schiff beladen
                    prgwo:=0;                                                            //  Anfang Programm
                    Bs_Update;                                                           //  Bildschirm-Update
                    Form1.M_Info.Text:=AnsiToUTF8('Bitte identifizieren Sie sich');
                    Form1.M_Info.Lines.Add(AnsiToUTF8('                                 4.. Taste'));
                  end;
                end;
           $30: begin                                                         //C Beladen
                  erg:=Beladen(false);
                  prgwo:=0;                                                            //  Anfang Programm
                  Bs_Update;                                                           //  Bildschirm-Update
                  Form1.M_Info.Text:=AnsiToUTF8('Bitte identifizieren Sie sich');
                  Form1.M_Info.Lines.Add(AnsiToUTF8('                               ... Ausweis'));
                end;
           $40: begin                                                         //C Entladen
                  erg:=Entladen(false);
                  prgwo:=0;                                                            //  Anfang Programm
                  Bs_Update;                                                           //  Bildschirm-Update
                  Form1.M_Info.Text:=AnsiToUTF8('Bitte identifizieren Sie sich');
                  Form1.M_Info.Lines.Add(AnsiToUTF8('                               ... Ausweis'));
                end;
           else begin
                  prgwo:=0;
                  Bs_Update;                                                           //  Bildschirm-Update
                  Form1.M_Info.Text:=AnsiToUTF8('Bitte identifizieren Sie sich');
                  Form1.M_Info.Lines.Add(AnsiToUTF8('                                 7.. Taste'));
                end;
           end;                                                                 //E case prgwo
         end;                                                                   //E if: Tastertureingabe
         rfid:='';                                                              //  Neuer Chip notwendig
       end;                                                                     //E Nummer
     end;                                                                       //E case: Taste, else
  end;                                                                          //E case: Taste
end;                                                                            //E procedure
//******************************************************************************
function OLActiveCaption:string;
var
   Handle:THandle;
   Len:LongInt;
   Title:string;
begin
   Handle:=GetForegroundWindow;
   Len:=GetWindowTextLength(Handle) + 1;
   SetLength(Title,Len);
   GetWindowText(Handle,PChar(Title),Len);
   OLActiveCaption:=TrimRight(Title);
end;
//******************************************************************************
procedure TForm1.FormCreate(Sender: TObject);
var
  h: THandle;
begin
  Randomize;
  keypreview:=true;
  h := GetSystemMenu(Handle, False);
  if h <> 0 then
  begin
    DeleteMenu(h, SC_CLOSE, MF_BYCOMMAND);
    DrawMenuBar(Handle);
  end;
  //Fehler:=$0000;                                                                //  Kein Fehler
  PrgPathLesen;                                                                 //  Startpfad lesen
  IniLesen;                                                                     //  Ini-File lesen
  AuftrLesen;
  EreignLesen;
  UseLesen;                                                                     //  Benutzte Codes lesen
  Bs_Update;                                                                    //  Bildschirm-Update
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  Application.MessageBox('Netzwerkfehler','',0);
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Tastenaw(Key);                                                                     //  Tasten auswerten
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  random(10000);
end;

end.
