// create example plugins db
// usage: deno run --allow-read=.. --allow-write=. plugins.js
// see https://deno-blog.com/Using_SQLite_with_Deno.2023-02-24

import { DB } from "https://deno.land/x/sqlite@v3.7.0/mod.ts";

let count = 0
async function allSites (kind,doit) {
  console.log({kind})
  for await (const dir of Deno.readDir("../sites")) {
    if(!dir.isDirectory) continue
    console.log(++count, dir.name)
    try {
      await allPages(dir.name,kind,doit)
    } catch(err) {
      if(err.code != "ENOENT") console.log('allSite', {err})
    }
  }
}

async function allPages (site,kind,doit) {
  // try {
  for await (const dir of Deno.readDir(`../sites/${site}/pages`)) {
    if(!dir.isDirectory) continue
    try {
      const file = await Deno.open(`../sites/${site}/pages/${dir.name}/${kind}.txt`, {read: true});
      const fileInfo = await file.stat();
      if (fileInfo.isFile) {
        const buf = new Uint8Array(10000);
        const bytes = await file.read(buf);
        const text = new TextDecoder().decode(buf);  // "hello world"
        doit(site,dir.name,text.slice(0,bytes).trim().split(/\n/))
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

// await allSites('plugins', (site,slug,plugins) => {
//   console.log(site,slug)
//   console.log(plugins.join(", "))
//   console.log('------------')
// })
// await allSites('items', (site,slug,items) => {
//   console.log(site)
//   console.log(items.join(", "))
//   console.log('------------')
// })
// Deno.exit()


// Open a database to be held in a file
const db = new DB("pages.db");
db.execute(`
  CREATE TABLE IF NOT EXISTS pages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    site TEXT,
    slug TEXT,
    plugin TEXT,
    item TEXT
  )`);

// Insert data within a transaction
const kind = 'plugin'
await allSites(kind+'s', (site,slug,data) => {
  // console.log(site,slug)
  db.transaction(() => {
    for (const each of data) {
      db.query(`INSERT INTO pages (site,slug,${kind}) VALUES (?,?,?)`, [site,slug,each]);
    }
  });
})

// Todo: Other CRUD operations here...

// Close database to clean up resources
// db.close()
