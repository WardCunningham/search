#  Run for yourself

You want to become a considerate maintainer of a federation scrape service.

These are steps that help you to get set up on Ubuntu Linux.

## Prerequisites

Install these dependencies, if not yet available to your system.

- cron
- sh
- ruby

Some optional dependencies exist for extended usage.

- caddy
- deno

```sh
sudo apt install -y ruby bundler
```

The repository comes with a `Gemfile` to describe Ruby dependencies.

Make sure you have a writable `GEM_HOME` directory, e.g. with adding to `.bashrc`:

```sh
export GEM_HOME="$(ruby -e 'puts Gem.user_dir')"
export PATH="$GEM_HOME/bin:$PATH"
```

Install the Ruby dependencies with:

```sh
bundle install
```

## Preparation

The code assumes in many place from where it is made available.
Adapt this location to your preference.

```sh
xargs -L1 sed 's/search.fed.wiki.org/search.federatedwiki.org/g' -i <<<"online.pl
  pages/welcome-visitors
  public/title-search.html
  public/title.html
  server.rb"
```

We also need a little upgrade, if we want to run from Ruby 3.

```sh
xargs -L1 sed 's/Dir.exists/Dir.exist/' -i <<<"slug-web.rb
site-web.rb"
```

You will need at least one seed site to start from. Additionally we prepare the
retired store.

Then prefill the index by an initial run of the cron script.

```sh
mkdir -p sites/{fed.wiki.org,fed.wiki,federated.wiki,verbund.wiki,commoning.wiki}/pages retired
LANG="en_US.UTF-8" sh cron.sh
```

Initially, this will take a lot of time. Wait for the process to complete.

Observe its doings for a current time window with e.g.:

```sh
tail -f logs/Tue-1800
```

An exemplary initial run took four and a half hours.

## Running

Running the federation wiki scraper requires to handle a few components.

See the [Subsystem Diagrams](http://scrape.fed.wiki/subsystem-diagrams.html)
and the [Resource Checklist](http://scrape.fed.wiki/resource-checklist.html)
for details.

More background can be explored from the [Search Overview](http://ward.asia.wiki.org/view/ruby-sitemap-scrape/view/how-scrape-works/view/search-index-downloads/view/sitemap-failures/view/sitemap-scrape-improvements/view/link-symmetry/view/newly-found-sites/view/full-scrape/scrape.ward.bay.wiki.org/how-search-works/scrape.ward.bay.wiki.org/search-overview) lineup.

### Activating scheduled cron execution

Add the `cron.sh` script to your user crontab.

```sh
( ( crontab -l ; echo "0 */6 * * * (cd $HOME/src/github.com/WardCunningham/search; LANG="en_US.UTF-8" sh cron.sh)" ) | crontab - ) >& /dev/null
```

### Starting the server

A systemd service unit is created with

```sh
systemctl edit --user --force --full wiki-search-server
```

Fill it with:

```ini
[Unit]
Description=Wiki search service
Requires=default.target

[Service]
Type=simple
Environment=APP_ENV=production
Environment=GEM_HOME=/home/ubuntu/.local/share/gem/ruby/3.2.0
WorkingDirectory=/home/ubuntu/src/github.com/WardCunningham/search
ExecStart=/usr/bin/ruby /home/ubuntu/src/github.com/WardCunningham/search/server.rb -p 3030
Restart=always
TimeoutSec=10

[Install]
WantedBy=default.target
```

Reload your daemon to use it.

```sh
systemctl daemon-reload --user
systemctl enable --user --now wiki-search-server
```

The search is now available at <http://search.federatedwiki.org:3030>.

Persist the user service with enabling linger mode:

```sh
sudo loginctl enable-linger ubuntu
```

For serving the query interface using the default HTTP port, use:

```
sudo cat <<CADDYFILE > /etc/caddy/Caddyfile
> {
  email acme@search.federatedwiki.org
}

http://query.search.federatedwiki.org, https://query.search.federatedwiki.org {
  reverse_proxy localhost:3030
}
CADDYFILE
sudo systemctl restart caddy
```

The query interface for the search is then also available at <http://query.search.federatedwiki.org>.
