(ttest) Czy opóźnienia znacząco różnią się w zależności od regionu?

region liczba op liczba nieop
 */

--wersja 1

with moje_dane as(
select DISTINCT wylot_kod_regionu region, count(*) over (PARTITION BY wylot_kod_regionu) liczba_wszystkich,
  count(CASE WHEN czas_opoznienia is not null then 1 END) over (PARTITION BY wylot_kod_regionu) liczba_opoznionych,
  count(case when czas_opoznienia is null then 1 end) over (PARTITION BY wylot_kod_regionu) liczba_na_czas
from o_trasy)
  select *, liczba_opoznionych/liczba_wszystkich::numeric proc_opoznionych, liczba_na_czas/liczba_wszystkich::numeric proc_na_czas
  from moje_dane

--pv=18,77%

-- wersja 2 wg kraju

with moje_dane as(
select DISTINCT wylot_kod_kraju kraj, count(*) over (PARTITION BY wylot_kod_kraju) liczba_wszystkich,
  count(CASE WHEN czas_opoznienia is not null then 1 END) over (PARTITION BY wylot_kod_kraju) liczba_opoznionych,
  count(case when czas_opoznienia is null then 1 end) over (PARTITION BY wylot_kod_kraju) liczba_na_czas
from o_trasy)
  select *, liczba_opoznionych/liczba_wszystkich::numeric proc_opoznionych, liczba_na_czas/liczba_wszystkich::numeric proc_na_czas
  from moje_dane
order by 2 DESC;

-- wybieram 2 największą liczbą lotów - DE i GB

with moje_dane as(
select to_char(plan_odjazd_data, 'MM') miesiac, wylot_kod_kraju kraj, czas_opoznienia
from o_trasy
where czas_opoznienia is not null
and (wylot_kod_kraju = 'DE' or wylot_kod_kraju = 'GB')
order by 1,2)
select distinct miesiac, kraj, avg(czas_opoznienia) over (PARTITION by miesiac, kraj)
from moje_dane
ORDER BY 1;

-- wrzucam do excela i licze pv=16,39
--wrzucam do tableau i robie wykres