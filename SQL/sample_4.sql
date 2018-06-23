--Jaki dzień w roku jest najbardziej obłożony biorąc pod uwagę liczbę pasażerów?

with moje_dane as (
    SELECT
      w.id,
      w.liczba_pasazerow liczba_pasazerow,
      to_char(s2.data_wyjazdu, 'MM-DD') dzien_wyjazdu
    FROM wnioski w
      JOIN podroze p ON w.id = p.id_wniosku
      JOIN szczegoly_podrozy s2 ON p.id = s2.id_podrozy
    ORDER BY 3
)
select distinct dzien_wyjazdu, sum(liczba_pasazerow) over (PARTITION by dzien_wyjazdu)
from moje_dane
order by 2 DESC;

--odp 22 stycznia