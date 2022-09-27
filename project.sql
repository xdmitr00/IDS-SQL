--Autori Patrik Hybský a Daria Dmitriievich
--Vymazanie tabuliek
drop table Transakcia;
drop table Disponent;
drop table Ucet;
drop table Klient;
drop table Zamestnanec;
drop table Pobocka;

--Vytvorenie tabuliek

create table Pobocka (
	id_pobocka int primary key,
	adresa varchar(128) UNIQUE NOT NULL
);

create table Zamestnanec (
	id_zamestnanec int primary key,
	meno varchar(32) NOT NULL,
	prijmeni varchar(32) NOT NULL,
	datum_narodenia date NOT NULL,
	datum_nastupu date NOT NULL,
	OP char(8) UNIQUE,
	pracuje_na_pobocke int NOT NULL -- foreign key zo zamestnanec
);

create table Klient (
	id_klient int primary key,
	meno varchar(32) NOT NULL,
	prijmeni varchar(32) NOT NULL,
	datum_narodenia date NOT NULL,
	telefonne_cislo char(13) NOT NULL UNIQUE,
	email varchar(64),
	OP char(8) UNIQUE 
);

create table Ucet (
	id_ucet char(24) primary key,
	typ_uctu varchar(16) NOT NULL,
	datum_zalozenia date NOT NULL,
	zustatek number(15,2) default 0,
	limit_uctu number(15,2),
	platobna_karta number(1) default 0,
	internetove_bankovnictvi number(1) default 0,
	sluzby_navyše varchar(256),
	vlastnik_uctu int NOT NULL, -- foreign key z klient
	zalozeny_zamestnancem int NOT NULL -- foreign key zo zamestnanec
);

create table Disponent (
	id_disponent int primary key,
	id_ucet char(24) NOT NULL, -- foreign key z ucet
	id_klient int NOT NULL, -- foreign key z klient
	limit_disponenta number(15,2),
	prava_disponenta varchar(256) NOT NULL,
	platobna_karta number(1) default 0
);

create table Transakcia (
	id_transkacia int primary key,
	suma number(15,2) NOT NULL,
	datum_vykonania DATE NOT NULL,
	datum_vytvorenia DATE NOT NULL,
	sposob_vytvorenia varchar(64) NOT NULL,
	ucet_prijemcu char(24) NOT NULL,
	id_ucet char(24) NOT NULL, -- foreign key z ucet
	id_disponent int default NULL, -- foreign key z disponent
	id_zamestnanec int default NULL-- foreign key zo zamestnanec, optional
);

-- Pridanie Foreign keys

alter table Zamestnanec add constraint FK_zamestnany foreign key (pracuje_na_pobocke) references Pobocka(id_pobocka);
alter table Ucet add constraint FK_zalozenyUcet foreign key (zalozeny_zamestnancem) references Zamestnanec(id_zamestnanec);
alter table Ucet add constraint FK_vlastnikUctu foreign key (vlastnik_uctu) references Klient(id_klient);
alter table Disponent add constraint FK_disponentUctu foreign key (id_ucet) references Ucet(id_ucet);
alter table Disponent add constraint FK_disponentKlient foreign key (id_klient) references Klient(id_klient);
alter table Transakcia add constraint FK_transakciaZUctu foreign key (id_ucet) references Ucet(id_ucet);
alter table Transakcia add constraint FK_transkaciaOdDsponenta foreign key (id_disponent) references Disponent(id_disponent);
alter table Transakcia add constraint FK_transakciaOdZamestnanca foreign key (id_zamestnanec) references Zamestnanec(id_zamestnanec);

-- Triggery
-- Trigger na vygenerovanie primarneho kluca pre Disponenta

drop sequence pkDisponentSq;
create sequence pkDisponentSq;
create or replace trigger dispnentGenPK
	before insert on Disponent
	for each row
begin
	if :new.id_disponent is NULL then
		:new.id_disponent := pkDisponentSq.nextval;
	end if;
end;
/
-- Trigger na aktualizovanie zostatku na ucte

create or replace trigger updateZostatok
	after insert on Transakcia
	for each row	
begin
	if :new.id_ucet <> :new.ucet_prijemcu then
		update Ucet set Ucet.zustatek = Ucet.zustatek + :new.suma where Ucet.id_ucet = :new.id_ucet;
		update Ucet set Ucet.zustatek = Ucet.zustatek - :new.suma where Ucet.id_ucet = :new.ucet_prijemcu;
	else
		update Ucet set Ucet.zustatek = Ucet.zustatek + :new.suma where Ucet.id_ucet = :new.id_ucet;
	end if;
end;
/

-- Vlozenie dat do tabuliek

insert into Pobocka(id_pobocka, adresa) values (1, 'M. R. Štefánika 29');
insert into Pobocka(id_pobocka, adresa) values (2, 'Obrancov Mieru 9');
insert into Zamestnanec(id_zamestnanec, meno, prijmeni, datum_narodenia, datum_nastupu, OP, pracuje_na_pobocke) values (1, 'Jozef', 'Mrkvička', TO_DATE('1970/05/03', 'yyyy/mm/dd'), TO_DATE('2020/05/03', 'yyyy/mm/dd'), 'ER557788', 1);
insert into Zamestnanec(id_zamestnanec, meno, prijmeni, datum_narodenia, datum_nastupu, OP, pracuje_na_pobocke) values (2, 'Štefan', 'Cibula', TO_DATE('1986/05/08', 'yyyy/mm/dd'), TO_DATE('2008/10/07', 'yyyy/mm/dd'), 'ER487213', 1);
insert into Zamestnanec(id_zamestnanec, meno, prijmeni, datum_narodenia, datum_nastupu, OP, pracuje_na_pobocke) values (3, 'Lukáš', 'Laššák', TO_DATE('1991/02/13', 'yyyy/mm/dd'), TO_DATE('2018/12/01', 'yyyy/mm/dd'), 'ER784162', 1);
insert into Zamestnanec(id_zamestnanec, meno, prijmeni, datum_narodenia, datum_nastupu, OP, pracuje_na_pobocke) values (4, 'Marián', 'Murgaš', TO_DATE('1989/07/27', 'yyyy/mm/dd'), TO_DATE('2014/11/21', 'yyyy/mm/dd'), 'ER484854', 2);
insert into Zamestnanec(id_zamestnanec, meno, prijmeni, datum_narodenia, datum_nastupu, OP, pracuje_na_pobocke) values (5, 'Pavel', 'Lukáč', TO_DATE('1965/01/04', 'yyyy/mm/dd'), TO_DATE('2013/06/08', 'yyyy/mm/dd'), 'ER841235', 2);
insert into Klient(id_klient, meno, prijmeni, datum_narodenia, telefonne_cislo, email, OP) values(1, 'Ivan', 'Ivan', TO_DATE('1987/04/04', 'yyyy/mm/dd'), '+421901123456', 'ivanko123@nejakyserver.sk', 'ER123321');
insert into Klient(id_klient, meno, prijmeni, datum_narodenia, telefonne_cislo, email, OP) values(2, 'Jakub', 'Kováč', TO_DATE('1999/09/21', 'yyyy/mm/dd'), '+420949201301', 'kovy@nejakyinyserver.cz', 'ER662266');
insert into Klient(id_klient, meno, prijmeni, datum_narodenia, telefonne_cislo, email, OP) values(3, 'Júlia', 'Ivanová', TO_DATE('1989/07/11', 'yyyy/mm/dd'), '+421911654321', 'julinka@nejakyserver.sk', 'ER321123');
insert into Ucet(id_ucet, typ_uctu, datum_zalozenia, zustatek, limit_uctu, platobna_karta, internetove_bankovnictvi, sluzby_navyše, vlastnik_uctu, zalozeny_zamestnancem) values ('SK4044440000001234567891', 'bežný', TO_DATE('2020/10/10', 'yyyy/mm/dd'), 0, 100, 1, 1, 'Poistenie, Úver', 1, 1);
insert into Ucet(id_ucet, typ_uctu, datum_zalozenia, zustatek, limit_uctu, internetove_bankovnictvi, sluzby_navyše, vlastnik_uctu, zalozeny_zamestnancem) values ('SK4044440000002345678912', 'sporiaci', TO_DATE('2021/01/01', 'yyyy/mm/dd'), 0, 50, 1, 'Žiadne', 2, 5);
insert into Disponent(id_ucet, id_klient, limit_disponenta, prava_disponenta, platobna_karta) values('SK4044440000001234567891', 1, 100, 'Plné oprávnenie', 1);
insert into Disponent(id_ucet, id_klient, limit_disponenta, prava_disponenta, platobna_karta) values('SK4044440000001234567891', 3, 50, 'Len platby a výber s kartou', 1);
insert into Disponent(id_ucet, id_klient, limit_disponenta, prava_disponenta) values('SK4044440000002345678912', 2, 50, 'Plné oprávnenie');
insert into Transakcia(id_transkacia, suma, datum_vykonania, datum_vytvorenia, sposob_vytvorenia, ucet_prijemcu, id_ucet, id_disponent) values(1, -21.45, TO_DATE('2020/03/01', 'yyyy/mm/dd'), TO_DATE('2020/02/28', 'yyyy/mm/dd'), 'Transakcia on-line', 'SK4044440000002345678912', 'SK4044440000001234567891', 1);
insert into Transakcia(id_transkacia, suma, datum_vykonania, datum_vytvorenia, sposob_vytvorenia, ucet_prijemcu, id_ucet, id_disponent, id_zamestnanec) values(2, 1, TO_DATE('2021/01/01', 'yyyy/mm/dd'), TO_DATE('2021/01/01', 'yyyy/mm/dd'), 'Vklad na pobočke', 'SK4044440000002345678912', 'SK4044440000002345678912', 3, 5);

-- Select dat z tabuliek

-- 2 tabulky, vypis zamestnancov, ktori vytvorili transakcie nad uctami
select Zamestnanec.meno, Zamestnanec.prijmeni, Transakcia.suma, Transakcia.id_ucet from Zamestnanec inner join Transakcia on Zamestnanec.id_zamestnanec = Transakcia.id_zamestnanec;
-- 2 tabulky, vypis klientov a ucty ktore vlastnia alebo im disponuju
select Klient.meno, Klient.prijmeni, Disponent.id_ucet from Disponent inner join Klient on Disponent.id_klient = Klient.id_klient;
-- 3 tabulky, vypis ktory zamestnanec vytvoril ucet danemu klientovi
select Zamestnanec.meno, Zamestnanec.prijmeni, Ucet.id_ucet, Klient.OP from Zamestnanec inner join Ucet on Zamestnanec.id_zamestnanec = Ucet.zalozeny_zamestnancem inner join Klient on Ucet.vlastnik_uctu = Klient.id_klient;
-- group by s agreg, vypis kolko ludi disponuje jednemu uctu
select id_ucet, count(*) pocet_disponentov from Disponent group by id_ucet;
-- group by s agreg, vypis celkovej sumy transakcii nad vsetkymi uctami
select id_ucet, sum(suma) celkova_suma_transakcii from Transakcia group by id_ucet;
-- exists, vypis vsetkych klientov, ktori nevlastnia vlastny ucet
select Klient.meno, Klient.prijmeni from Klient where not exists (select Ucet.id_ucet from Ucet where Ucet.vlastnik_uctu = Klient.id_klient);
-- in vnoreny select, vypis vsetkych klientov ktori maju limit na vlastnom ucte mensi ako 75
select Klient.meno, Klient.prijmeni from Klient where Klient.id_klient in (select Ucet.vlastnik_uctu from Ucet where Ucet.limit_uctu < 75);

-- Test triggeru dispnentGenPK
select * from Disponent;
-- Test triggeru updateZostatok
select * from Ucet;	

-- Procedury
-- Procedura na vypis poctu transakcii a celkovu ciastku transakcie ktore 

create or replace procedure getTrans(IBAN in varchar) as
cursor trans is select * from Transakcia;
pocet integer;
sucet integer;
tr Transakcia%rowtype;
begin
	pocet := 0;
	sucet := 0;
	open trans;
	loop
		fetch trans into tr;
		exit when trans%notfound;
		if IBAN = tr.ucet_prijemcu then
			pocet := pocet + 1;
			sucet := sucet + tr.suma;
		elsif IBAN = tr.id_ucet then
			pocet := pocet + 1;
			sucet := sucet - tr.suma;
		end if;
	end loop;
	dbms_output.put_line('Nad uctom ' || IBAN || ' bolo vykonanych ' || pocet || ' s celkovou sumou ' || sucet);
exception
	when no_data_found then
		raise_application_error(99, 'Nenasli sa data v tabulke Transakcia');
	when others then
		raise_application_error(99, 'Interna chyba procedury getTrans');
end;
/

-- Procedura na vypis klientov so zahranicnymi cislom

create or replace procedure	 findForeignPN as
cursor kl is select * from Klient;
k Klient%rowtype;
begin
	open kl;
	loop
		fetch kl into k;
		exit when kl%notfound;
		if not k.telefonne_cislo is NULL and not regexp_like (k.telefonne_cislo, '^\+421[0-9]{9}$') then
			dbms_output.put_line('Klient ' || k.meno || ' ' || k.prijmeni || ' ma cislo so zahranicnou predvolbou ' || k.telefonne_cislo);
		end if;
	end loop;
exception
	when no_data_found then
		raise_application_error(99, 'Nenasli sa data v tabulke Klient');
	when others then
		raise_application_error(99, 'Interna chyba procedury findForeignPN');
end;
/

-- Test procedury getTrans
exec getTrans('SK4044440000001234567891');
-- Test procedury findForeignPN
exec findForeignPN;

-- explain plan na vypisanie kolko zamestnancov pracuje v kazdej pobocke

explain plan for select	Pobocka.id_pobocka, Pobocka.adresa, count(*) pocet_zamestnancov from Pobocka inner join Zamestnanec on Pobocka.id_pobocka = Zamestnanec.pracuje_na_pobocke group by Pobocka.id_pobocka, Pobocka.adresa;
select plan_table_output from table (dbms_xplan.display());
-- index na optimalizaciu adresy pobocky

create index index1 on Pobocka(id_pobocka, adresa);

-- explain plan s optilamizaciou

explain plan for select	Pobocka.id_pobocka, Pobocka.adresa, count(*) pocet_zamestnancov  from Pobocka inner join Zamestnanec on Pobocka.id_pobocka = Zamestnanec.pracuje_na_pobocke group by Pobocka.id_pobocka, Pobocka.adresa;
select plan_table_output from table (dbms_xplan.display());
-- Oprávnenia pre druhého člena týmu pre tabulky

grant all on Pobocka to xdmitr00;
grant all on Zamestnanec to xdmitr00;
grant all on Klient to xdmitr00;
grant all on Ucet to xdmitr00;
grant all on Disponent to xdmitr00;
grant all on Transakcia to xdmitr00;

-- Oprávnenia pre druhého člena týmu pre procedury

grant execute on getTrans to xdmitr00;
grant execute on findForeignPN to xdmitr00;

-- Materializovany pohlad pre xdmitr00

drop materialized view zamestnanecNaPobocke;
create materialized view zamestnanecNaPobocke cache build immediate refresh on commit as
select xhybsk00.Zamestnanec.meno, xhybsk00.Zamestnanec.prijmeni, xhybsk00.Pobocka.adresa
from xhybsk00.Zamestnanec inner join xhybsk00.Pobocka on xhybsk00.Zamestnanec.pracuje_na_pobocke = xhybsk00.Pobocka.id_pobocka;

-- Test materializovaneho pohladu

insert into xhybsk00.Zamestnanec(id_zamestnanec, meno, prijmeni, datum_narodenia, datum_nastupu, OP, pracuje_na_pobocke) values (6, 'Eva', 'Horváthová', TO_DATE('1989/06/11', 'yyyy/mm/dd'), TO_DATE('2021/05/01', 'yyyy/mm/dd'), 'ER775566', 2);
-- Vypisanie nezmenenych zamestnancov
select * from zamestnanecNaPobocke;
commit;
-- Vypis uz aj naposledy pridaneho zamestnanca
select * from zamestnanecNaPobocke;