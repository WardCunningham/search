// create example plugins db
// usage: deno run --allow-read=.. --allow-write=. plugins.js
// see https://deno-blog.com/Using_SQLite_with_Deno.2023-02-24

import { DB } from "https://deno.land/x/sqlite@v3.7.0/mod.ts";

async function allPlugins (kind,doit) {
  for await (const dir of Deno.readDir("../sites")) {
    if(!dir.isDirectory) continue
    try {
      const file = await Deno.open(`../sites/${dir.name}/${kind}.txt`, {read: true});
      const fileInfo = await file.stat();
      if (fileInfo.isFile) {
        const buf = new Uint8Array(10000);
        const bytes = await file.read(buf);
        const text = new TextDecoder().decode(buf);  // "hello world"
        doit(dir.name,text.slice(0,bytes).trim().split(/\n/))
      }
      file.close();
    } catch(err) {
      if(err.code != "ENOENT") console.log({err})
    }
  }
}

// await allPlugins('plugins', (site,plugins) => {
//   console.log(site)
//   console.log(plugins.join(", "))
//   console.log('------------')
// })
// await allPlugins('items', (site,items) => {
//   console.log(site)
//   console.log(items.join(", "))
//   console.log('------------')
// })
// Deno.exit()


// Open a database to be held in a file
const db = new DB("sites.db");
db.execute(`
  CREATE TABLE IF NOT EXISTS sites (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    site TEXT,
    plugin TEXT,
    item TEXT
  )`);

// Insert data within a transaction
const kind = 'plugin'
await allPlugins(kind+'s', (site,data) => {
  console.log(site)
  db.transaction(() => {
    for (const each of data) {
      db.query(`INSERT INTO sites (site,${kind}) VALUES (?,?)`, [site,each]);
    }
  });
})

// Todo: Other CRUD operations here...

// Close database to clean up resources
db.close()
