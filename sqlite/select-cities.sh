# Select fields for cities of interest
# Usage: cd sqlite; sh select-cites.sh > geonames-us.json

cat geonames-all-cities-with-a-population-1000.json |\
 jq '[
   .[] |
   select(.cou_name_en=="United States") |
   [{name:.ascii_name, state:.admin1_code}, .population, .coordinates]
 ]'