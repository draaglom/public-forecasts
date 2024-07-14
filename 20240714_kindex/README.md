question set:

 - https://www.metaculus.com/questions/26145/between-july-17-and-july-28-2024-will-the-strongest-geomagnetic-storm-have-a-k-index-kp-greater-than-4-and-less-than-or-equal-to-6/
 - https://www.metaculus.com/questions/26143/between-july-17-and-july-28-2024-will-the-strongest-geomagnetic-storm-have-a-k-index-kp-greater-than-5-and-less-than-or-equal-to-6/
 - https://www.metaculus.com/questions/26144/between-july-17-and-july-28-2024-will-the-strongest-geomagnetic-storm-have-a-k-index-kp-greater-than-4-and-less-than-or-equal-to-5/

data source: https://kp.gfz-potsdam.de/app/files/Kp_ap_since_1932.txt

refresh data with:

```bash
./get-timeseries.sh
```

forecast with:

```bash
ruby kp_markov.rb
```

methodology:

- pretty naive random markov chain on all data since 1932-present
- assumes it won't be run while the question window is open
