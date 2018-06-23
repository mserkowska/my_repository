-- Jaki jest potencjał poszczególnych regionów?
--Ile pociągów jest opóźnionych / anulowanych i jaka jest całkowita wartość rekompensaty?


--jakie sa rodzaje statusow
select distinct przylot_status from o_trasy;
--dy opozniony
--cx anulowany
--ot na czas
--ey wczesniej
--ns brak info
--null brak info - uznajemy za anulowane

with moje_dane AS (
    SELECT
     wylot_kod_regionu,
     CASE
     WHEN przylot_status = 'CX'
      THEN 'anulowane'
     WHEN przylot_status = 'DY'
      THEN 'opoznione'
     WHEN przylot_status IS NULL
      THEN 'anulowane'
     ELSE '0' END      status,
     count(*)          liczba_pociagow,
     sum(rekompensata) suma_rekompensat
    FROM o_trasy
    WHERE czy_uprawniony = TRUE
    GROUP BY 1, 2
)
select *,sum(liczba_pociagow) over(partition by wylot_kod_regionu) sum_liczba_pociagow,
  (liczba_pociagow/sum(liczba_pociagow) over(partition by wylot_kod_regionu)) procent_pociagow
  from moje_dane;