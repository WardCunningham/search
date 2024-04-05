// create example plugins db
// usage: deno run --allow-read=.. --allow-write=. plugins.js
// see https://deno-blog.com/Using_SQLite_with_Deno.2023-02-24

import { DB } from "https://deno.land/x/sqlite@v3.7.0/mod.ts";

async function allPlugins (doit) {
  for await (const dir of Deno.readDir("../sites")) {
    if(!dir.isDirectory) continue
    try {
      const file = await Deno.open(`../sites/${dir.name}/plugins.txt`, {read: true});
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

await allPlugins((site,plugins) =>
  console.log(site,plugins.join(", ")))
Deno.exit()


  // Open a database to be held in a file
  const db = new DB("plugins.db"); 
  db.execute(`
  CREATE TABLE IF NOT EXISTS sites (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    site TEXT
    plugin TEXT
  )`);

  // Insert data within a transaction
  db.transaction(() => {
    for (const name of ["Peter Parker", "Clark Kent", "Bruce Wayne"]) {
      db.query("INSERT INTO people (name) VALUES (?)", [name]);
    }
  });

  // Todo: Other CRUD operations here...

  // Close database to clean up resources
  db.close()
