// Retrieve all changes for last week from scrape logs
// usage: deno run --allow-net fed-changes.json

const sleep = msec => new Promise(res => setTimeout(res,msec))
const asSlug = (title) => title.replace(/\s/g, '-').replace(/[^A-Za-z0-9-]/g, '').toLowerCase()

let site = `http://search.fed.wiki.org:3030`
let list = await fetch(`${site}/logs`).then(res => res.text())
let logs = list.trim().split(/\n/).map(line => line.split('"')[1])
let seen = new Set()

for (let log of logs) {
  console.log(new Date())
  let text = await fetch(`${site}${log}`).then(res => res.text())
  let who, what, match
  for (let line of text.split(/\n/)) {
    match = line.match(/^([\w.-]+), (\d+) pages$/)
    if (match) {who = match[1]}
    match = line.match(/^\t(.+?), (\d+) days ago$/)
    if (match) {
      what = match[1]
      if(!seen.has(who+what))
        console.log(log,who,asSlug(what))
      seen.add(who+what)
    }
  }
  await sleep(500)
}