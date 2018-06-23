--Z którego kraju mamy najwięcej wniosków?
select kod_kraju, count(*)
from wnioski
group BY kod_kraju
order by 2 desc;

--Z którego języka mamy najwięcej wniosków?
select jezyk, count(*)
from wnioski
group BY jezyk
order by 2 desc;

--Ile % procent klientów podróżowało w celach biznesowych a ilu w celach prywatnych?
select typ_podrozy,
count(*)/sum(count(*)) over()::numeric procent_klientow
  from wnioski
GROUP BY typ_podrozy;

--Jak procentowo rozkładają się źródła polecenia?
select zrodlo_polecenia,
  count(*)/sum(count(*)) over ()::numeric procent_zrodlo_polecenie
from wnioski
GROUP BY zrodlo_polecenia;

--Ile podróży to trasy złożone z jednego / dwóch / trzech / więcej tras?
SELECT id, count(*),
  CASE
    when count(*) is null then 'brak'
    when count(*) =1 then 'jedna trasa'
    when count(*) =2 then 'dwie trasy'
    when count(*) =3 then 'trzy trasy'
    else 'więcej niż trzy trasy'
    end
FROM szczegoly_podrozy
  group by 1;
--i tu by trzeba zrobic tabele przestawną w excelu

--Na które konto otrzymaliśmy najwięcej / najmniej rekompensaty?
select konto, count(*) liczba_rekompensat
  from szczegoly_rekompensat
group by konto
order by liczba_rekompensat desc;

--Który dzień jest rekordowym w firmie w kwestii utworzonych wniosków?
select to_char(data_utworzenia, 'YYYY-MM-DD') dzien_utworzenia,
  count(*) liczba_wnioskow
  from wnioski
GROUP BY 1
ORDER BY liczba_wnioskow DESC;

--Który dzień jest rekordowym w firmie w kwestii otrzymanych rekompensat?
select to_char(data_otrzymania, 'YYYY-MM-DD') dzien_otrzymania,
  count(*) liczba_rekompensat
  from szczegoly_rekompensat
GROUP BY dzien_otrzymania
order by liczba_rekompensat DESC;

--Jaka jest dystrubucja tygodniowa wniosków według kanałów? (liczba wniosków w danym tygodniu w każdym kanale)
    SELECT
      to_char(data_utworzenia, 'YYYY-WW') AS tydzien, kanal, count(1) liczba
    FROM wnioski
    GROUP BY 1, 2;
--i tu by trzeba zrobic pivot w excelu


--Lista wniosków przeterminowanych (przeterminowany = utworzony w naszej firmie powyżej 3 lat od daty podróży)

--sprawy do wyjasnienia - wnioski zlozone przed data podróży
select w.id id_wniosku, w.data_utworzenia data_utworzenia, p.id id_podrozy,
  s.data_wyjazdu::timestamp data_wyjazdu
from wnioski w
join podroze p
on w.id=p.id_wniosku
join szczegoly_podrozy s ON p.id = s.id_podrozy
where w.data_utworzenia<s.data_wyjazdu;
--wnioski pow 3 lat
select w.id id_wniosku, w.data_utworzenia data_utworzenia, p.id id_podrozy,
  s.data_wyjazdu::timestamp data_wyjazdu, extract(days from w.data_utworzenia-data_wyjazdu) dni
from wnioski w
join podroze p
on w.id=p.id_wniosku
join szczegoly_podrozy s ON p.id = s.id_podrozy
where w.data_utworzenia>s.data_wyjazdu
      AND
extract(days from w.data_utworzenia-data_wyjazdu)>1095;


--Badanie powracających klientów
--Firmie zależy na tym, aby klienci do nas wracali.
--Jaka część naszych klientów to powracające osoby?

select k.email, count(1)
from wnioski w
JOIN klienci k ON w.id = k.id_wniosku
  group by 1
ORDER BY 2 DESC;


Jaka część naszych współpasażerów to osoby, które już wcześniej pojawiły się na jakimś wniosku?
select w.email, count(1)
  from wspolpasazerowie w
  group by 1
ORDER BY 2 desc;


--Jaka część klientów pojawiła się na innych wnioskach jako współpasażer?
-- pierwsza czesc pokazuje liste, chcialam dodac union zeby byla suma ale nie wiem dlaczego nie dziala???
with moje_dane as(
SELECT k.email klient, w.email wspolpasazer, count(1) liczba
  from klienci k
  LEFT JOIN wspolpasazerowie w
    on k.email=w.email
where w.email is not null
group by 1,2)

select *
from moje_dane
UNION
select 'razem', sum(liczba)
from moje_dane;


--Czy jako nowy klient mający kilka zakłóceń, od razu składasz kilka wniosków?
--Jaki jest czas od złożenia pierwszego do kolejnego wniosku?

select k.email as klient, w.data_utworzenia data_utworzenia_1_wniosku,
  count(2) over (PARTITION BY k.email),
  lead(w.data_utworzenia) over (PARTITION BY k.email) data_utworzenia_2_wniosku,
  lead(w.data_utworzenia) over (PARTITION BY k.email)-w.data_utworzenia
from klienci k
    join wnioski w ON k.id_wniosku = w.id
  GROUP BY 1,2
order by 3 DESC;

