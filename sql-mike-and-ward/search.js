// create example plugins db
// usage: deno run --allow-read --allow-write=. search.js
// see https://deno-blog.com/Using_SQLite_with_Deno.2023-02-24

import { DB } from "https://deno.land/x/sqlite@v3.7.0/mod.ts";

const dbfile = 'search.db'
await Deno.remove(dbfile);
const db = new DB(dbfile);
const insert = {} // kind => prepared statement

function create () {
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
}

let count = 0
// const kind = 'plugin'

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
  console.log('allSites done')
}

async function allPages (site) {
  for await (const dir of Deno.readDir(`../sites/${site}/pages`)) {
    if(!dir.isDirectory) continue
    try {
      const slug = dir.name
      await eachPage(site,slug)
    } catch(err) {
      if(err.code != "ENOENT") console.log('allPages', {err})
    }
  }
}

async function allKinds (site,slug,kind,doit) {
      const file = await Deno.open(`../sites/${site}/pages/${slug}/${kind+'s'}.txt`, {read: true});
      const fileInfo = await file.stat();
      if (fileInfo.isFile) {
        const buf = new Uint8Array(10000);
        const bytes = await file.read(buf);
        const text = new TextDecoder().decode(buf);  // "hello world"
        doit(text.slice(0,bytes).trim().split(/\n/))
      }
      file.close();
}

async function eachPage(site,slug) {
  const [[uid]] = db.query(`INSERT INTO pages (site,slug) VALUES (?,?) RETURNING id`, [site,slug]);
  for (const kind of ['plugin','item']) {
    if(!(kind in insert)) insert[kind] = db.prepareQuery(`INSERT INTO ${kind+'s'} (page,${kind}) VALUES (?,?)`)
    await allKinds(site,slug,kind,data => {
      db.transaction(() => {
        // console.log({slug,kind,length:data.length})
        for (const each of data) {
          insert[kind].execute([uid,each])
        }
      })
    })
  }
}

create()
await allSites()
for (const kind in insert)
  insert[kind].finalize()    
// db.close()
console.log('done')
