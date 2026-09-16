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
