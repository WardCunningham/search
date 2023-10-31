# Select fields for cities of interest
# Usage: cd sqlite; sh select-all-cites.sh > geonames.json

cat geonames-all-cities-with-a-population-1000.json |\
 jq '[
   .[] |
   [{name:.ascii_name, state:.admin1_code, country:.cou_name_en}, .population, .coordinates]
 ]'