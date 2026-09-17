# UBIKA service status page

Repo for https://status.ubika.io

## Internal e-mail notifications

Incidents are exposed as an RSS feed at <https://status.ubika.io/index.xml>
(one item per incident, template: `layouts/index.xml`). Each item carries
machine-readable `<category>` entries: `status:ongoing|resolved`,
`severity:<value>`, `type:informational`, `affected:<component>` (one per
component) and `resolvedWhen:<date>`.

Internal notifications are sent by a Power Automate flow (Microsoft 365), not
by this repository:

1. Trigger **RSS – When a feed item is published**, feed URL
   `https://status.ubika.io/index.xml`, chosen property **PublishDate**.
2. Action **Office 365 Outlook – Send an email (V2)** to the internal
   distribution list, using the feed item title, link, categories and summary.

The trigger only fires for items whose `date` is newer than the last poll, so
new incidents must be published with a `date` close to the actual publication
time (not back-dated by hours). Updates to an existing incident do not trigger
a notification.

## Local build

Hugo Extended is pinned in `.hugo-version` (shared with the GitHub Actions
workflow). The `Makefile` downloads that exact version into `.bin/` (ignored by
git), so no system-wide install is needed:

```sh
make serve   # live-reload dev server on http://127.0.0.1:1313/
make build   # production build into public/ (same flags as CI)
make check   # build + validate public/index.xml (RSS feed used by the e-mail flow)
```

Requirements: `make`, `curl`, `tar`, `git`, `python3` (feed validation).

### Upgrading Hugo or the cState theme

1. Change the version in `.hugo-version` and/or `cd themes/cstate && git checkout <tag>`.
2. Run `make check` and compare the result with the current site.
3. Some files under `layouts/` are project-level copies of theme templates
   (each has a header comment explaining why): `index.xml` (RSS categories),
   `_default/small.html` (Hugo >= 0.146 template lookup) and
   `partials/index/summary.html` (RSS link fix, upstream PR #358). Diff them
   against `themes/cstate/layouts/` and port any upstream change, or delete
   them once the theme ships the fix.
4. Push a branch and open a pull request: the workflow builds the site without
   deploying it, and the `github-pages` artifact of the run can be downloaded
   and served locally as a preview. Deployment only happens on `main`.
