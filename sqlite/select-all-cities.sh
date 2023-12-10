# Select fields for cities of interest
# Usage: cd sqlite; sh select-all-cities.sh > geonames-all.json

cat geonames-all-cities-with-a-population-1000.json |\
 jq '[
   .[] |
   [{name:.ascii_name, state:(if .cou_name_en=="United States" then .admin1_code+" USA" else .cou_name_en end )}, .population, .coordinates]
 ]'