// create example plugins db
// usage: deno run --allow-read=.. --allow-write=. search.js
// see https://deno-blog.com/Using_SQLite_with_Deno.2023-02-24

import { DB } from "https://deno.land/x/sqlite@v3.7.0/mod.ts";
const kind = 'plugin'

let count = 0
async function allSites () {
   for await (const dir of Deno.readDir("../sites")) {
    if(!dir.isDirectory) continue
    console.log(++count, new Date().toLocaleTimeString(), dir.name)
    try {
      await allPages(dir.name)
    } catch(err) {
      if(err.code != "ENOENT") console.log('allSite', {err})
    }
    // if(count > 5) break
  }
}

async function allPages (site) {
  // try {
  for await (const dir of Deno.readDir(`../sites/${site}/pages`)) {
    if(!dir.isDirectory) continue
    try {
      const file = await Deno.open(`../sites/${site}/pages/${dir.name}/${kind+'s'}.txt`, {read: true});
      const fileInfo = await file.stat();
      if (fileInfo.isFile) {
        const buf = new Uint8Array(10000);
        const bytes = await file.read(buf);
        const text = new TextDecoder().decode(buf);  // "hello world"
        eachPage(site,dir.name,text.slice(0,bytes).trim().split(/\n/))
      }
      file.close();
    } catch(err) {
      if(err.code != "ENOENT") console.log('allPages', {err})
    }
  }
  // } catch(err) {
  //   console.log('readDir', {err})
  // }
}

function eachPage(site,slug,data) {
  // const insertpage = db.prepareQuery(`INSERT INTO pages (site,slug) VALUES (?,?) RETURNING id`)

  const [[uid]] = db.query(`INSERT INTO pages (site,slug) VALUES (?,?) RETURNING id`, [site,slug]);
  // const [[uid]] = insertpage.execute([site,slug]);
  db.transaction(() => {
    for (const each of data) {
      // db.query(`INSERT INTO ${kind+'s'} (page,${kind}) VALUES (?,?)`, [uid,each]);
      insertkind.execute([uid,each])
    }
  })
}


// https://www.sqlite.org/foreignkeys.html
const db = new DB("search-test.db");
db.execute(`
  CREATE TABLE pages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    site TEXT,
    slug TEXT,
    UNIQUE(site,slug)
  );
  CREATE TABLE plugins (
    page INTEGER,
    plugin TEXT
  );
  CREATE TABLE items (
    page INTEGER,
    item TEXT
  );
  PRAGMA synchronous = OFF;
  PRAGMA journal_mode = MEMORY;`);

const insertkind = db.prepareQuery(`INSERT INTO ${kind+'s'} (page,${kind}) VALUES (?,?)`)
await allSites()

// Close database to clean up resources
console.log('done')
db.close()
