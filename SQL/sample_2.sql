--1) Jaka data była 8 dni temu?

select extract(day from now())-8;

--2) Jaki dzień tygodnia był 3 miesiące temu?

select to_char(now()-interval '3 weeks', 'Day');

--3) W którym tygodniu roku jest 01 stycznia 2017?

with moje_dni as (
select
generate_series(
      date_trunc('day', '2018-01-01'::date),
      date_trunc('day', '2018-12-31'::date), interval '1 day') dzien
      )
      select dzien, to_char(dzien, 'WW') nr_tygodnia
      from moje_dni
      where dzien = '2018-01-01';

--4) Podaj listę wniosków z właściwym operatorem (który rzeczywiście przeprowadził trasę)

select w.id, s.identyfikator_operator_operujacego
from wnioski w
join podroze p ON w.id = p.id_wniosku
join szczegoly_podrozy s ON p.id = s.id_podrozy
where s.identyfikator_operator_operujacego is not null;


--5) Przygotuj listę klientów z datą utworzenia ich pierwszego i drugiego wniosku.
------ 3 kolumny: email, data 1wszego wniosku, data 2giego wniosku

select distinct k.email as klient,
 first_value(w.data_utworzenia) over (partition by k.email order by w.data_utworzenia) data_1_wniosku,
nth_value(w.data_utworzenia,2) over (partition by k.email order by w.data_utworzenia) data_2_wniosku
from klienci k
    join wnioski w ON k.id_wniosku = w.id
order by 3 ASC ;


--6) Używając pełen kod do predykcji wniosków, zmień go tak aby uwzględnić kampanię marketingową,
-- która odbędzie się 26 lutego - przewidywana liczba wniosków z niej to 1000

with moje_daty as (select -- to jest odpowiedzialne za wygenerowanie dat z przyszlosci
  generate_series(
      date_trunc('day', '2018-01-20'::date), -- jaki jest pierwszy dzien generowania
      date_trunc('month', now())+interval '1 month'-interval '1 day', -- koncowy dzien generowania
      '1 day')::date as wygenerowana_data --interwał, co ile dni/miesiecy/tygodni dodawac kolejne rekordy
  ),
aktualne_wnioski as ( -- to jest kawalek odpowiedzialny za aktualna liczba wnioskow
    select to_char(data_utworzenia, 'YYYY-MM-DD')::date data_wniosku, count(1) liczba_wnioskow
    from wnioski
    group by 1
  ),
lista_z_wnioskami as (
    select md.wygenerowana_data, -- dla danej daty
      coalesce(aw.liczba_wnioskow,0) liczba_wnioskow, -- powiedz ile bylo wnioskow w danym dniu, jesli byl NULL dodajemy coalesce
      sum(aw.liczba_wnioskow) over(order by md.wygenerowana_data) skumulowana_liczba_wnioskow -- laczna liczba wnioskow dzien po dniu
    from moje_daty md
    left join aktualne_wnioski aw on aw.data_wniosku = md.wygenerowana_data --left join dlatego, ze niektore dni nie maja jeszcze wnioskow. wlasnie dla nich bede robil predykcje
    order by 1),
statystyki_dnia as (
    select to_char(wygenerowana_data, 'Day') dzien, round(avg(liczba_wnioskow)) przew_liczba_wnioskow -- round aby nie uzupelniac liczbami zmiennoprzecinkowymi
    from lista_z_wnioskami
      where wygenerowana_data <= '2018-02-09'
    group by 1
    order by 1
    )
select lw.wygenerowana_data, liczba_wnioskow, przew_liczba_wnioskow,
  case
    when wygenerowana_data <= '2018-02-09' then liczba_wnioskow
    when wygenerowana_data = '2018-02-26' then 1000+przew_liczba_wnioskow
       else przew_liczba_wnioskow end finalna_liczba_wnioskow, -- dodaje case aby wybrac realna liczbe albo przewidywana w zaleznosci od daty

  sum(case
    when wygenerowana_data <= '2018-02-09' then liczba_wnioskow
    else przew_liczba_wnioskow end) over(order by wygenerowana_data) skumulowana_z_predykcja -- dodaje funkcje okna aby zsumowac wartosci zarowo realne jak i predykcje
from lista_z_wnioskami lw
join statystyki_dnia sd on sd.dzien = to_char(lw.wygenerowana_data, 'Day')

--7) Używając pełen kod do predykcji wniosków, zmień go tak aby uwzględnić
-- przymusową przerwę serwisową, w sobotę 24 lutego nie będzie można utworzyć żadnych wniosków

with moje_daty as (select -- to jest odpowiedzialne za wygenerowanie dat z przyszlosci
  generate_series(
      date_trunc('day', '2018-01-20'::date), -- jaki jest pierwszy dzien generowania
      date_trunc('month', now())+interval '1 month'-interval '1 day', -- koncowy dzien generowania
      '1 day')::date as wygenerowana_data --interwał, co ile dni/miesiecy/tygodni dodawac kolejne rekordy
  ),
aktualne_wnioski as ( -- to jest kawalek odpowiedzialny za aktualna liczba wnioskow
    select to_char(data_utworzenia, 'YYYY-MM-DD')::date data_wniosku, count(1) liczba_wnioskow
    from wnioski
    group by 1
  ),
lista_z_wnioskami as (
    select md.wygenerowana_data, -- dla danej daty
      coalesce(aw.liczba_wnioskow,0) liczba_wnioskow, -- powiedz ile bylo wnioskow w danym dniu, jesli byl NULL dodajemy coalesce
      sum(aw.liczba_wnioskow) over(order by md.wygenerowana_data) skumulowana_liczba_wnioskow -- laczna liczba wnioskow dzien po dniu
    from moje_daty md
    left join aktualne_wnioski aw on aw.data_wniosku = md.wygenerowana_data --left join dlatego, ze niektore dni nie maja jeszcze wnioskow. wlasnie dla nich bede robil predykcje
    order by 1),
statystyki_dnia as (
    select to_char(wygenerowana_data, 'Day') dzien, round(avg(liczba_wnioskow)) przew_liczba_wnioskow -- round aby nie uzupelniac liczbami zmiennoprzecinkowymi
    from lista_z_wnioskami
      where wygenerowana_data <= '2018-02-09'
    group by 1
    order by 1
    )
select lw.wygenerowana_data, liczba_wnioskow, przew_liczba_wnioskow,
  case
    when wygenerowana_data <= '2018-02-09' then liczba_wnioskow
    when wygenerowana_data = '2018-02-24' then '0'
       else przew_liczba_wnioskow end finalna_liczba_wnioskow, -- dodaje case aby wybrac realna liczbe albo przewidywana w zaleznosci od daty

  sum(case
    when wygenerowana_data <= '2018-02-09' then liczba_wnioskow
    else przew_liczba_wnioskow end) over(order by wygenerowana_data) skumulowana_z_predykcja -- dodaje funkcje okna aby zsumowac wartosci zarowo realne jak i predykcje
from lista_z_wnioskami lw
join statystyki_dnia sd on sd.dzien = to_char(lw.wygenerowana_data, 'Day')

--8) Ile (liczbowo) wniosków zostało utworzonych poniżej
-- mediany liczonej z czasu między lotem i wnioskiem?

with moje_dane AS (
    SELECT
      w.data_utworzenia data_utworzenia,
      s.data_wyjazdu data_wyjazdu,
      extract(DAY FROM (w.data_utworzenia - s.data_wyjazdu)) czas
    FROM wnioski w
      JOIN podroze p ON w.id = p.id_wniosku
      JOIN szczegoly_podrozy s ON p.id = s.id_podrozy
    WHERE extract(DAY FROM (w.data_utworzenia - s.data_wyjazdu)) > 0
    GROUP BY 1, 2
    ORDER BY 3 ASC
)
select percentile_cont(0.5) within group(order by (extract(DAY FROM (data_utworzenia - data_wyjazdu))) asc) mediana
from moje_dane
;

--mediana = 43

with moje_dane AS (
    SELECT
      w.data_utworzenia                                      data_utworzenia,
      s.data_wyjazdu                                         data_wyjazdu,
      extract(DAY FROM (w.data_utworzenia - s.data_wyjazdu)) czas
    FROM wnioski w
      JOIN podroze p ON w.id = p.id_wniosku
      JOIN szczegoly_podrozy s ON p.id = s.id_podrozy
    WHERE extract(DAY FROM (w.data_utworzenia - s.data_wyjazdu)) > 0 AND
          extract(DAY FROM (w.data_utworzenia - s.data_wyjazdu)) < 43
    GROUP BY 1, 2
    ORDER BY 3 ASC
)
select count(*)
from moje_dane;

--odp 67753

 --9) Mając czas od utworzenia wniosku do jego analizy przygotuj statystyke:
--jaka jest mediana czasu?
--jaka jest srednia czasu?
--jakie mamy wartości odstające?

  WITH moje_dane AS (
      SELECT
        w.data_utworzenia,
        a.data_zakonczenia,
        extract(DAYS FROM (a.data_zakonczenia - w.data_utworzenia)) czas
      FROM wnioski w
        JOIN analizy_wnioskow a ON w.id = a.id_wniosku
      ORDER BY 3 ASC
  )
  SELECT
    percentile_cont(0.5)
    WITHIN GROUP (ORDER BY czas ASC) mediana,
    avg(czas)                        srednia,
    min(czas)                        min,
    max(czas)                        max
    FROM moje_dane;

--ile jest wnioskow ponizej p75?

with moje_dane as(
SELECT  w.data_utworzenia,
        a.data_zakonczenia,
        extract(DAYS FROM (a.data_zakonczenia - w.data_utworzenia)) czas
      FROM wnioski w
        JOIN analizy_wnioskow a ON w.id = a.id_wniosku
      ORDER BY 3 ASC
  )
select percentile_cont(0.75) WITHIN GROUP (ORDER BY czas ASC) p75
  from moje_dane;

-- p75=0

with moje_dane as(
SELECT  w.data_utworzenia,
        a.data_zakonczenia,
        extract(DAYS FROM (a.data_zakonczenia - w.data_utworzenia)) czas
      FROM wnioski w
        JOIN analizy_wnioskow a ON w.id = a.id_wniosku
  where extract(DAYS FROM (a.data_zakonczenia - w.data_utworzenia))<0
        ORDER BY 3 ASC)
select count(*)
    from moje_dane;

--odp 3701


--ile jest wnioskow powyzej p25?

with moje_dane as(
SELECT  w.data_utworzenia,
        a.data_zakonczenia,
        extract(DAYS FROM (a.data_zakonczenia - w.data_utworzenia)) czas
      FROM wnioski w
        JOIN analizy_wnioskow a ON w.id = a.id_wniosku
      ORDER BY 3 ASC
  )
select percentile_cont(0.25) WITHIN GROUP (ORDER BY czas ASC) p25
  from moje_dane;

-- p25=0

with moje_dane as(
SELECT  w.data_utworzenia,
        a.data_zakonczenia,
        extract(DAYS FROM (a.data_zakonczenia - w.data_utworzenia)) czas
      FROM wnioski w
        JOIN analizy_wnioskow a ON w.id = a.id_wniosku
  where extract(DAYS FROM (a.data_zakonczenia - w.data_utworzenia))>0
        ORDER BY 3 ASC)
select count(*)
    from moje_dane;

--odp 20915

--czy te dane znacząco roznią się jesli rozbijemy je na zaakceptowane i odrzucone?

--ile jest zaakceptowanych wnioskow ponizej p75?

with moje_dane as(
SELECT  w.data_utworzenia,
        a.data_zakonczenia,
        extract(DAYS FROM (a.data_zakonczenia - w.data_utworzenia)) czas
      FROM wnioski w
        JOIN analizy_wnioskow a ON w.id = a.id_wniosku
  where status='zaakceptowany'
      ORDER BY 3 ASC
  )
select percentile_cont(0.75) WITHIN GROUP (ORDER BY czas ASC) p75
  from moje_dane;

-- p75=0

with moje_dane as(
SELECT  w.data_utworzenia,
        a.data_zakonczenia,
        extract(DAYS FROM (a.data_zakonczenia - w.data_utworzenia)) czas
      FROM wnioski w
        JOIN analizy_wnioskow a ON w.id = a.id_wniosku
         where status='zaakceptowany' and
   extract(DAYS FROM (a.data_zakonczenia - w.data_utworzenia))<0
        ORDER BY 3 ASC)
select count(*)
    from moje_dane;

--odp 3696, wszystkich bylo 3701

--ile jest zaakceptowanych wnioskow powyzej p25?

with moje_dane as(
SELECT  w.data_utworzenia,
        a.data_zakonczenia,
        extract(DAYS FROM (a.data_zakonczenia - w.data_utworzenia)) czas
      FROM wnioski w
        JOIN analizy_wnioskow a ON w.id = a.id_wniosku
   where status='zaakceptowany'
      ORDER BY 3 ASC
  )
select percentile_cont(0.25) WITHIN GROUP (ORDER BY czas ASC) p25
  from moje_dane;

-- p25=0

with moje_dane as(
SELECT  w.data_utworzenia,
        a.data_zakonczenia,
        extract(DAYS FROM (a.data_zakonczenia - w.data_utworzenia)) czas
      FROM wnioski w
        JOIN analizy_wnioskow a ON w.id = a.id_wniosku
         where status='zaakceptowany' and
   extract(DAYS FROM (a.data_zakonczenia - w.data_utworzenia))>0
        ORDER BY 3 ASC)
select count(*)
    from moje_dane;

--odp 17661, dla wszystkich bylo  20915



--10) Chcę bardziej spersonalizować naszą stronę internetową pod wymagania klientów.
--Aby to zrobić potrzebuję analizy dotyczącej języków używanych przez klientów:
--Jakich języków używają klienci? (kolumny: jezyk, liczba klientow, % klientow)

with moje_dane as (
select w.jezyk jezyk, k.email klient
from wnioski w
join klienci k ON w.id = k.id_wniosku
ORDER BY 1)
select distinct jezyk, count(klient) over (partition by jezyk) liczba_klientow, count(klient) over (partition by jezyk)/count(klient) over ()::numeric proc_klientow
from moje_dane
order by 2 DESC ;

--Jak często klient zmienia język (przeglądarki)? (kolumny: email, liczba zmian,

with moje_dane as (
    SELECT
      w.jezyk jezyk,
      k.email email
    FROM wnioski w
      JOIN klienci k ON w.id = k.id_wniosku
    ORDER BY 2
)
select distinct email, count(jezyk) over (partition by email) liczba_zmian
from moje_dane
order by 2 desc;

--czy ostatni jezyk wniosku zgadza sie z pierwszym jezykiem wniosku)

with moje_dane2 AS (
  WITH moje_dane AS (
      SELECT
        w.data_utworzenia data_utw,
        w.jezyk           jezyk,
        k.email           email
      FROM wnioski w
        JOIN klienci k ON w.id = k.id_wniosku
      ORDER BY 3, 1
  )
  SELECT
    email,
    first_value(jezyk)
    OVER (
      PARTITION BY email ) jezyk_pierwszego_wniosku,
    last_value(jezyk)
    OVER (
      PARTITION BY email ) jezyk_ostatnieg_wniosku
  FROM moje_dane
)
select *
from moje_dane2
    where jezyk_pierwszego_wniosku <> jezyk_ostatnieg_wniosku;

-- tak


