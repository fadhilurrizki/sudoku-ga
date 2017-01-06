unit sudoku;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type
    populasi = array[1..10000,1..9,1..9] of integer ;
    individu = array[1..9,1..9] of integer;
    fitness   = array[1..10000] of integer;
  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    mrunning: TMemo;
    mhasil: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
   p : populasi ;
   fit,fitinv,fitkum : fitness ;
   u : boolean;
   aa : char;
   ind1,ind2,anak1,anak2 : individu;
   teks : string;
   i,j,k,x,y,l,m,r1,r2,min,max,totalfit,generasi,fitt,rand1,rand2,jlhpopulasi,probmutasi : integer;
implementation

{$R *.lfm}

{ TForm1 }
function generatepopulasi():populasi;
var
   a : populasi;
   temp : integer;
begin
     for k:=1 to jlhpopulasi do
     begin
          for i:=1 to 9 do
          begin
               for j:= 1 to 9 do
               begin
                    a[k,i,j]:=j;
               end;
          end;
     end;
     for k:=1 to jlhpopulasi do
     begin
          for i:=1 to 9 do
          begin
               for j:= 1 to 9 do
               begin
                    rand1:= random(9)+1;
                    rand2:=random(9)+1;
                    temp:=a[k,i,rand1];
                    a[k,i,rand1]:=a[k,i,rand2];
                    a[k,i,rand2]:=temp;
               end;
          end;
     end;
     generatepopulasi := a;
end;
function getfitness(ind : individu) : integer ;
var
   f : individu;
   x1,y1,n,o: integer;
begin
     fitt:=0;
     for i:=1 to 9 do
         for j:= 1 to 9 do
             f[i,j]:=0;
     for i:=1 to 9 do
     begin
          for j:=1 to 9 do
          begin
               for l:=1 to 9 do
               begin
                    if((ind[i,j]=ind[i,l])and(j<>l)) then
                    begin
                         f[i,j]:=1;
                    end;
                    if((ind[i,j]=ind[l,j])and(i<>l)) then
                    begin
                             f[i,j]:=1;
                    end;
               end;
               x1:=trunc(i/3)+1;
               y1:=trunc(j/3)+1;
               x1:=x1*3;
               y1:=y1*3;
               for l:=x1-2 to x1 do
               begin
                    for m:=y1-2 to y1 do
                    begin
                         if((ind[i,j]=ind[l,m])and(i<>l)and(j<>m)) then
                         begin
                              f[i,j]:=1;
                         end;
                    end;
               end;
          end;
     end;

     for i:=1 to 9 do
     begin
          for j:= 1 to 9 do
          begin
               fitt:=fitt+f[i,j];
          end;
     end;
     getfitness := fitt;
end;
function kumulatiffitness(f:fitness): fitness;
var
   jlh : integer;
   kf : fitness;
begin
     jlh:=0;
     for k:=1 to jlhpopulasi do
     begin
         jlh:=jlh+f[k];
         kf[k]:=jlh;
     end;
     kumulatiffitness := kf;
end;
function roulette(n : integer;f : fitness) : integer;
begin
   k:=1;
   while (k<=jlhpopulasi) do
   begin
        if(fit[k]>=n) then
        begin
                   x:=k;
                   break;
        end;
        k:=k+1;
   end;
   roulette := x;
end;
function crossover(i1 : individu; i2:individu) : individu;
var
   ind : individu;
   q,w: boolean;
   z: integer;
begin
     for i:= 1 to 9 do
         for j:=1 to 9 do
             if((j<4)or(j>6))then
                                 ind[i,j]:=i1[i,j]
             else
                 ind[i,j]:=i2[i,j];
  {   for i:=1 to 6 do
      begin
          if((i<3)or(i>4))then
          begin
          for j:=1 to 6 do
          begin
               q:=false;
               k:=1;
               while((k<=6)) do
               begin
                    if(c[k]=j) then
                               x:= true;
                    k:=k+1;
               end;
               if(x=false)then
               begin
                          c[i]:=j;
                          break;
               end;
          end;
           end;
      end;  }
     for i:= 1 to 9 do
     begin
         for j:=1 to 9 do
         begin
             if((j<4)or(j>6))then
             begin
                  w:=false; z:=0;
                  while((w=false)and(z<=9))do
                  begin
                       q:=false;
                       l:=1;
                       while((l<=9)and(q=false)) do
                       begin
                            if((ind[i,j]=ind[i,l])and(l<>j)) then
                               q:= true;
                            l:=l+1;
                       end;
                       if(q=false)then
                                      w:=true
                       else
                       begin
                          z:=z+1;
                          ind[i,j]:=z;
                       end;
                  end;
             end;
         {    for k:=1 to 9 do
             begin
                 x:=0;
                 for l:=1 to 9 do
                 begin
                     if(ind[i,l]=k) then
                     begin
                          x:=x +1;
                     end;
                 end;
                 if(x>0) then
                         ind[i,j]:=k;
             end; }
         end;
     end;
     crossover := ind;
end;
function mutasi(indd:individu) : individu;
var
   c,x,p : integer;
   titikmutasi,hasil : array[1..9] of integer;
   mutant: array[1..9,1..9] of integer;
begin
  { c:=0;
   for i:=1 to 9 do
       titikmutasi[i]:=0;
   for i:=1 to 9 do
   begin
       for j:=1 to 9 do
       begin
           rand1:=random(100)+1;
           if(rand1<=probmutasi)then
           begin
              c:=c+1;
              titikmutasi[c]:=j;
           end;
       end;
   end;  }
 {  for i:=1 to 8 do
   begin
       x:=indd[titikmutasi[i]];
       if(titikmutasi[i+1]=0)then
       begin
          indd[tittikmutasi[i]]:=indd[1];
       end
       else
           indd[tittikmutasi[i]]:=indd[titikmutasi[i+1]];
       indd[titikmutasi[i+1]]
   end; }
   {randomize;
   rand1 := random(9)+1;
   randomize;
   rand2 := random(9)+1;
   randomize;
   x := random(100)+1;
   if(x<20) then
   begin
        for i:=1 to 9 do
        begin
             c:=indd[i,rand1];
             indd[i,rand1]:=indd[i,rand2];
             indd[i,rand2]:=c;
        end;
   end;           }

   for j:=1 to 9 do
   begin
       c:=0;
        for i:=1 to 9 do
            hasil[i]:=indd[j,i];
        for i:=1 to 9 do
            titikmutasi[i]:=0;
        for i:=1 to 9 do
        begin
          rand1:=random(100)+1;
          if(rand1<probmutasi)then
          begin
             c:=c+1;
             titikmutasi[c]:=i;
          end;
        end;
        i:=1;
        while((titikmutasi[i]<>0)and(i<=9)) do
        begin
             x:=hasil[titikmutasi[i]];
             if((titikmutasi[i+1]=0)or(i=9))then
             begin
                 hasil[titikmutasi[i]]:=hasil[titikmutasi[1]];
                 hasil[titikmutasi[1]]:=x;
             end
             else
             begin
                  hasil[titikmutasi[i]]:=hasil[titikmutasi[i+1]];
                  hasil[titikmutasi[i]]:=x;
             end;
             i:=i+1;
        end;
       { for i:=1 to 9 do
         write(indd[1,i]);
        writeln;
        for i:=1 to 9 do
         write(titikmutasi[i]);
        writeln;
        for i:=1 to 9 do
         write(mutant[1,i]);
        writeln; }
        for i:=1 to 9 do
            mutant[j,i]:=hasil[i];
     {   for i:=1 to 9 do
            write(mutant[j,i]);
        writeln; }
   end;

   mutasi := mutant;
end;
procedure TForm1.Button1Click(Sender: TObject);
begin
        randomize;
        mrunning.Lines.Clear;
        mhasil.Lines.Clear;
        if(Edit1.caption<>'')and(Edit2.caption<>'') then
        begin
             jlhpopulasi:=StrtoInt(Edit1.caption);
             probmutasi:=StrtoInt(Edit2.caption);
        end;
        if((jlhpopulasi<=100000)and(jlhpopulasi>=1))then
        begin
             {generate populasi}
             p := generatepopulasi();
             {generate populasi}

             {for k:=1 to jlhpopulasi do
             begin
                  for i:= 1 to 9 do
                  begin
                       for j:=1 to 9 do
                       begin
                            write(p[k,i,j]);
                       end;
                       writeln;
                  end;
                  writeln;
             end; }

             {nilai fitness tiap individu}
              for k:=1 to jlhpopulasi do
              begin
                   for i:=1 to 9 do
                   begin
                        for j:=1 to 9 do
                        begin
                             ind1[i,j]:=p[k,i,j];
                        end;
                   end;
                   fit[k]:=getfitness(ind1);
              end;
              {nilai fitness tiap individu}
              for k:=1 to jlhpopulasi do
                  fitinv[k]:=81-fit[k];
              {kumulatif fitness}
              fitkum := kumulatiffitness(fitinv);
              {kumulatif fitness}

              {for k:=1 to 20 do
                   writeln(fitkum[k]);   }
              u:=false ;
              generasi:=1;
              while(u=false) do
              begin
                   {roulette wheels}
                   rand1 := random(fitkum[jlhpopulasi])+1;
                   rand2 := random(fitkum[jlhpopulasi])+1;
                   while(rand1=rand2)  do
                   begin
                     rand1 := random(fitkum[jlhpopulasi])+1;
                     rand2 := random(fitkum[jlhpopulasi])+1;
                   end;
                   {while(rand1=rand2)  do
                   begin
                        rand1 := random(fitkum[jlhpopulasi])+1;
                        rand2 := random(fitkum[jlhpopulasi])+1;
                   end;}
                   r1 := roulette(rand1,fitkum);
                   r2 := roulette(rand2,fitkum);
                   { r1:=1;
                   for k:=1 to jlhpopulasi do
                   begin
                        if(fit[r1]>fit[k]) then
                        begin
                             r1 := k;
                        end;
                   end;
                   r2:=1;
                   for k:=1 to jlhpopulasi do
                   begin
                        if((fit[r2]>fit[k])and(r1<>r2)) then
                        begin
                             r2 := k;
                        end;
                   end;       }
                   {roulette wheels}
                   {cross over}
                   for i:=1 to 9 do
                       for j:=1 to 9 do
                           ind1[i,j]:=p[r1,i,j];
                   for i:=1 to 9 do
                       for j:=1 to 9 do
                           ind2[i,j]:=p[r2,i,j];
                   anak1:=crossover(ind1,ind2);
                   anak2:=crossover(ind2,ind1);
                  { for i:= 1 to 9 do
                   begin
                        for j:=1 to 9 do
                        begin
                             write(ind1[i,j]);
                        end;
                        writeln;
                   end;
                   writeln;
                   for i:= 1 to 9 do
                   begin
                        for j:=1 to 9 do
                        begin
                             write(ind2[i,j]);
                        end;
                        writeln;
                   end;
                   writeln;
                   for i:= 1 to 9 do
                   begin
                        for j:=1 to 9 do
                        begin
                             write(anak1[i,j]);
                        end;
                        writeln;
                   end;
                   writeln;
                   for i:= 1 to 9 do
                   begin
                        for j:=1 to 9 do
                        begin
                             write(anak2[i,j]);
                        end;
                        writeln;
                   end;
                   writeln;
                   writeln('-----------');   }
                   {cross over}
                   {mutasi}
                   anak1:=mutasi(anak1);
                   anak2:=mutasi(anak2);
                   {mutasi}

                   {elitism}
                {  for k:=1 to jlhpopulasi do
                       write(' ',fit[k]);
                   writeln; }
                   max :=1;
                   for k:=1 to jlhpopulasi do
                   begin
                        if(fit[max]<fit[k]) then
                        begin
                             max := k;
                        end;
                   end;
                   {   writeln('max : ',max); }
                   fitt := getfitness(anak1);
                   {    writeln('fitness anak1 : ',fitt);     }
                   if(fit[max]>fitt) then
                   begin
                        for i:=1 to 9 do
                        begin
                             for j:=1 to 9 do
                             begin
                                  p[max,i,j]:=anak1[i,j];
                             end;
                        end;
                        fit[max]:=fitt;
                   end;
                   max :=1;
                   for i:=1 to jlhpopulasi do
                   begin
                        if(fit[max]<fit[i]) then
                        begin
                             max := i;
                        end;
                   end;
                   {  writeln('max : ',max);   }
                   fitt := getfitness(anak2);
                   { writeln('fitness anak2 : ',fitt);   }
                   if(fit[max]>fitt) then
                   begin
                        for i:=1 to 9 do
                        begin
                             for j:=1 to 9 do
                             begin
                                  p[max,i,j]:=anak2[i,j];
                             end;
                        end;
                        fit[max]:=fitt;
                   end;

              {elitism}
             for k:=1 to jlhpopulasi do
                 fitinv[k]:=81-fit[k];
             fitkum := kumulatiffitness(fitinv);
             for i:=1 to jlhpopulasi do
             begin
                  if((fit[i]=0)or(generasi >50000))then
                                  u:=true;
             end;
             mrunning.Lines.Add('generasi ke-'+InttoStr(generasi));
        min:=1;
        for i:=1 to jlhpopulasi do
        begin
             if(fit[i]<fit[min]) then
                            min:=i;
        end;
        mrunning.Lines.AddStrings('fitness : '+FloattoStr(fit[min]/81));
        generasi:=generasi+1;
        end;
        mhasil.Lines.Add('Generasi : '+ InttoStr(generasi-1));
        mhasil.Lines.Add('individu terbaik : ');
        for i:= 1 to 9 do
        begin
             teks:='';
             for j:=1 to 9 do
             begin
                  teks:=teks+InttoStr(p[max,i,j]) + ' ';
             end;
             mhasil.Lines.Add(teks);
        end;
        mhasil.Lines.Add('fitness : '+FloattoStr(fit[max]/81));
        {mhasil.Lines.Add('Generasi : '+ InttoStr(generasi-1)); }
        end;

end;

procedure TForm1.FormCreate(Sender: TObject);
begin

end;

end.

