// Map field and grid square to largest city
// Usage deno run --allow-write=. grid-cities.js 'us'

const region = Deno.args[0] || 'us'
console.log('reading',`geonames-${region}.json`)
const text = await Deno.readTextFile(`geonames-${region}.json`)
const cities = JSON.parse(text)
cities.sort((a,b) => b[1] - a[1])
console.log(cities.slice(0,4))

const fields = {}
const squares = {}
for (const [city,pop,geo] of cities) {
  const {name,state} = city
  if(!state) continue
  if(!state)console.log({city,pop,geo})
  const row = () => `${name}, ${state.split(',')[0]}, ${Object.values(geo).join(", ")}`
  const alpha = (deg,max) => 'ABCDEFGHIJKLMNOPQR'[Math.floor(18*(deg+max)/(2*max))]||'?'
  const numeric = (deg,span) => '0123456789'[Math.floor(deg%span/span*10)]||`?`
  const field = `${alpha(geo.lon,180)}${alpha(geo.lat,90)}`
  if(!(field in fields)) fields[field] = row()
  const square = `${field}${numeric(geo.lon+180,20)}${numeric(geo.lat+90,10)}`
  if(!(square in squares)) squares[square] = row()
}

await save(fields, `fields-${region}.json`)
await save(squares, `squares-${region}.json`)

async function save(obj, filename) {
  const ordered = Object.fromEntries(
    Object.entries(obj)
      .sort((a,b) => a[0]<b[0] ? -1 : 1))
  return Deno.writeTextFile(filename, JSON.stringify(ordered,null,2))
}